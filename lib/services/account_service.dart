import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountService {
  final _supabase = Supabase.instance.client;

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
      debugPrint('Iniciando transferência de $fromUserId para $toUserId no valor de $amount');
      
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
      final response = await _supabase.rpc('transfer_between_accounts', params: {
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
}

// Extensão para formatar dados sensíveis
extension SensitiveDataExtension on String {
  String obscureSensitiveData() {
    if (length <= 4) return this;
    return '••••${substring(length - 4)}';
  }
}
