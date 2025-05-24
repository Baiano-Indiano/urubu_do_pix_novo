import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urubu_do_pix_novo/models/paginated_response.dart';
import 'package:urubu_do_pix_novo/services/cache_service.dart';
import 'package:urubu_do_pix_novo/services/api_service.dart';

class AccountService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Busca os dados de uma conta pelo ID do usuário
  Future<Map<String, dynamic>?> getAccountByUserId(String userId) async {
    try {
      // Primeiro busca os dados da conta
      final accountResponse = await _supabase
          .from('accounts')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      if (accountResponse != null) {
        // Depois busca os dados do usuário
        final userResponse = await _supabase
            .from('users')
            .select('nome, cpf, email, telefone')
            .eq('user_id', userId)
            .maybeSingle();

        if (userResponse != null) {
          return {
            ...accountResponse,
            'user_data': userResponse,
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar conta: $e');
      return null;
    }
  }

  // Busca uma conta por CPF, e-mail ou telefone
  Future<Map<String, dynamic>?> searchAccount(String searchTerm) async {
    try {
      // Remove caracteres não numéricos para busca por CPF/telefone
      final cleanSearch = searchTerm.replaceAll(RegExp(r'[^0-9a-zA-Z@.]'), '');

      // Primeiro, busca o usuário
      final userResponse = await _supabase
          .from('users')
          .select('''
            user_id, 
            nome, 
            cpf, 
            email, 
            telefone
          ''')
          .or('cpf.eq.$cleanSearch,email.eq.$searchTerm,telefone.eq.$cleanSearch')
          .maybeSingle();

      if (userResponse != null) {
        // Depois, busca o saldo da conta
        final accountResponse = await _supabase
            .from('accounts')
            .select('balance')
            .eq('user_id', userResponse['user_id'])
            .maybeSingle();

        return {
          'user_id': userResponse['user_id'],
          'nome': userResponse['nome'],
          'cpf': userResponse['cpf'],
          'email': userResponse['email'],
          'telefone': userResponse['telefone'],
          'balance': (accountResponse?['balance'] ?? 0.0).toDouble(),
        };
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar conta: $e');
      return null;
    }
  }

  // Realiza uma transferência entre contas
  Future<Map<String, dynamic>> transfer({
    required String fromUserId,
    required String toUserId,
    required double amount,
    String? description,
  }) async {
    try {
      debugPrint(
          'Iniciando transferência de $fromUserId para $toUserId no valor de $amount');

      // Verifica se as contas existem
      final fromAccount = await getAccountByUserId(fromUserId);
      if (fromAccount == null) {
        debugPrint('Conta de origem não encontrada: $fromUserId');
        return {'success': false, 'error': 'Conta de origem não encontrada'};
      }

      final toAccount = await getAccountByUserId(toUserId);
      if (toAccount == null) {
        debugPrint('Conta de destino não encontrada: $toUserId');
        return {'success': false, 'error': 'Conta de destino não encontrada'};
      }

      // Verifica se há saldo suficiente
      final fromBalance = (fromAccount['balance'] ?? 0.0).toDouble();
      if (fromBalance < amount) {
        debugPrint('Saldo insuficiente: $fromBalance < $amount');
        return {'success': false, 'error': 'Saldo insuficiente'};
      }

      // Inicia uma transação
      debugPrint('Chamando função transfer_between_accounts no banco de dados');
      final response =
          await _supabase.rpc('transfer_between_accounts', params: {
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'amount': amount,
        'description': description ?? 'Transferência entre contas',
      }).timeout(const Duration(seconds: 10));

      debugPrint('Transferência realizada com sucesso: $response');
      return {'success': true, 'data': response};
    } catch (e) {
      debugPrint('Erro na transferência: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Busca histórico de transações com paginação e cache
  Future<PaginatedResponse<Map<String, dynamic>>> getTransactionHistory({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Tenta obter do cache primeiro
      final cacheKey = 'transactions_${userId}_$page';
      final cached = await CacheService.getFromCache(cacheKey);

      // Verifica se o cache está válido (não mais que 5 minutos)
      if (cached != null) {
        final lastUpdate = await CacheService.getLastUpdateTime(cacheKey);
        final now = DateTime.now();
        if (lastUpdate != null &&
            now.difference(lastUpdate) <= const Duration(minutes: 5)) {
          return PaginatedResponse<Map<String, dynamic>>.fromJson(
            cached,
            (item) => Map<String, dynamic>.from(item),
          );
        }
      }

      // Se não estiver em cache ou estiver expirado, busca no servidor
      final response = await _supabase
          .from('transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      // Primeiro busca o total de itens
      final countResponse = await _supabase
          .from('transactions')
          .select('id')
          .eq('user_id', userId);

      final totalItems = countResponse.length;
      final totalPages = (totalItems / limit).ceil();
      final hasNext = page < totalPages;

      final result = {
        'items': response,
        'current_page': page,
        'total_pages': totalPages,
        'total_items': totalItems,
        'has_next': hasNext,
        'last_update': DateTime.now().toIso8601String(),
      };

      // Salva no cache com compressão
      await CacheService.saveToCache(
        cacheKey,
        result,
        duration: const Duration(minutes: 5),
        compress: true,
      );

      // Pré-carrega a próxima página se houver
      if (hasNext) {
        _prefetchNextPage(userId, page + 1, limit);
      }

      return PaginatedResponse<Map<String, dynamic>>.fromJson(
        result,
        (item) => Map<String, dynamic>.from(item),
      );
    } catch (e) {
      debugPrint('Erro ao buscar histórico: $e');
      throw ApiException(
        message:
            'Não foi possível carregar o histórico de transações. Por favor, tente novamente mais tarde.',
        originalError: e,
      );
    }
  }

  Future<void> _prefetchNextPage(String userId, int page, int limit) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      final cacheKey = 'transactions_${userId}_$page';
      await CacheService.saveToCache(
        cacheKey,
        {
          'items': response,
          'current_page': page,
          'last_update': DateTime.now().toIso8601String(),
        },
        duration: const Duration(minutes: 5),
        compress: true,
      );
    } catch (e) {
      // Ignora erros no prefetch
      debugPrint('Erro no prefetch da página $page: $e');
    }
  }

  // Busca saldo com cache
  Future<double> getCachedBalance(String userId) async {
    try {
      final cacheKey = 'balance_$userId';
      final cachedBalance = await CacheService.getFromCache(cacheKey);

      if (cachedBalance != null) {
        return double.parse(cachedBalance.toString());
      }

      final account = await getAccountByUserId(userId);
      final balance = (account?['balance'] ?? 0.0).toDouble();

      // Salva no cache por 1 minuto
      await CacheService.saveToCache(
        cacheKey,
        balance,
        duration: const Duration(minutes: 1),
      );

      return balance;
    } catch (e) {
      debugPrint('Erro ao buscar saldo em cache: $e');
      rethrow;
    }
  }

  // Atualiza o cache do saldo
  Future<void> updateCachedBalance(String userId, double newBalance) async {
    try {
      final cacheKey = 'balance_$userId';
      await CacheService.saveToCache(
        cacheKey,
        newBalance,
        duration: const Duration(minutes: 1),
      );
    } catch (e) {
      debugPrint('Erro ao atualizar cache do saldo: $e');
    }
  }
}

// Extensão para formatar dados sensíveis
extension SensitiveDataExtension on String {
  String obscureSensitiveData() {
    if (length <= 4) return this;
    return '••••${substring(length - 4)}';
  }
}
