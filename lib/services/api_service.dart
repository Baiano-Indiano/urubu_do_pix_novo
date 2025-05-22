import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Alias para facilitar o uso
void logDebug(String message) => debugPrint('ApiService: $message');

class ApiService {
  final SupabaseClient _supabase;
  
  ApiService({SupabaseClient? supabase}) 
      : _supabase = supabase ?? Supabase.instance.client;

  // --- Cotação real via AwesomeAPI ---
  Future<Map<String, double>> fetchCotacoes() async {
    try {
      final response = await _supabase.functions.invoke('cotacoes', body: {});
      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'dolar': double.parse(data['dolar'].toString()),
          'euro': double.parse(data['euro'].toString()),
        };
      } else {
        throw Exception('Não foi possível buscar as cotações no momento.');
      }
    } catch (e) {
      logDebug('Erro ao buscar cotações: $e');
      rethrow;
    }
  }

  // --- Saldo/histórico por usuário autenticado ---
  Future<double> fetchSaldo() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Você precisa estar logado para acessar esta funcionalidade.');
      
      final data = await _supabase
          .from('accounts')
          .select('balance')
          .eq('user_id', userId)
          .single();
          
      return (data['balance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      logDebug('Erro ao buscar saldo: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchHistorico() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Você precisa estar logado para acessar esta funcionalidade.');
      
      final data = await _supabase
          .from('transfers')
          .select()
          .eq('user_id', userId)
          .order('data', ascending: false);
          
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      logDebug('Erro ao buscar histórico: $e');
      rethrow;
    }
  }

  Future<String?> uploadProfilePhoto(File file, String userId) async {
    try {
      final storage = _supabase.storage.from('profile-photos');
      final filePath = 'user_$userId/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      
      await storage.upload(filePath, file);
      final url = storage.getPublicUrl(filePath);
      
      // Atualiza a URL da foto no perfil do usuário
      await updateUserProfile(userId: userId, foto: url);
      
      return url;
    } catch (e) {
      logDebug('Erro ao fazer upload da foto: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return data;
    } catch (e) {
      logDebug('Erro ao buscar perfil do usuário: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String userId, 
    String? nome, 
    String? telefone, 
    String? foto
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (nome != null) updateData['nome'] = nome;
      if (telefone != null) updateData['telefone'] = telefone;
      if (foto != null) updateData['foto'] = foto;
      
      if (updateData.isNotEmpty) {
        updateData['updated_at'] = DateTime.now().toIso8601String();
        await _supabase
            .from('users')
            .update(updateData)
            .eq('user_id', userId);
      }
    } catch (e) {
      logDebug('Erro ao atualizar perfil: $e');
      rethrow;
    }
  }
  
  // Método de compatibilidade para telas antigas
  Future<void> updateProfilePhotoUrl(String userId, String url) async {
    await updateUserProfile(userId: userId, foto: url);
  }

  Future<void> registrarTransferencia(
    String destinatario, 
    double valor, {
    String? moeda, 
    double? valorOriginal,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');
      
      // Verifica o saldo atual
      final accountData = await _supabase
          .from('accounts')
          .select('balance')
          .eq('user_id', userId)
          .single();
          
      final currentBalance = (accountData['balance'] as num?)?.toDouble() ?? 0.0;
      
      if (currentBalance < valor) {
        throw Exception('Saldo insuficiente para realizar esta operação.');
      }
      
      // Inicia uma transação
      await _supabase.rpc('transfer_between_accounts', params: {
        'from_user_id': userId,
        'to_user_id': destinatario,
        'amount': valor,
        'description': 'Transferência entre contas',
      });
      
    } catch (e) {
      logDebug('Erro ao registrar transferência: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> getExchangeRates() async {
    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/BRL'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Falha ao carregar as cotações. Código: ${response.statusCode}');
      }
      
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (data['result'] != 'success') {
        throw Exception('Falha na resposta da API de cotações');
      }
      
      final rates = data['rates'] as Map<String, dynamic>;
      return {
        'USD': 1 / (rates['USD'] ?? 1.0),
        'EUR': 1 / (rates['EUR'] ?? 1.0),
      };
    } catch (e) {
      logDebug('Erro ao buscar taxas de câmbio: $e');
      rethrow;
    }
  }
  
  // Verifica se um CPF/CNPJ já está cadastrado
  Future<bool> checkIfDocumentExists(String document, {bool isCpf = true}) async {
    try {
      final cleanDoc = document.replaceAll(RegExp(r'[^0-9]'), '');
      final response = await _supabase
          .from('users')
          .select('user_id')
          .eq('cpf', cleanDoc)
          .maybeSingle();
          
      return response != null;
    } catch (e) {
      logDebug('Erro ao verificar documento: $e');
      return false;
    }
  }
  
  // Busca usuário por CPF/CNPJ
  Future<Map<String, dynamic>?> findUserByDocument(String document) async {
    try {
      final cleanDoc = document.replaceAll(RegExp(r'[^0-9]'), '');
      final response = await _supabase
          .from('users')
          .select()
          .eq('cpf', cleanDoc)
          .maybeSingle();
          
      return response;
    } catch (e) {
      logDebug('Erro ao buscar usuário por documento: $e');
      return null;
    }
  }
  
  // Métodos de compatibilidade para telas existentes
  String? get usuarioAtual => _supabase.auth.currentUser?.id;
  
  bool get isLoggedIn => _supabase.auth.currentUser != null;
  
  Future<bool> login(String identificador, String senha) async {
    try {
      String email;
      if (identificador.contains('@')) {
        email = identificador;
      } else {
        email = '${identificador.replaceAll(RegExp(r'[^0-9]'), '')}@urubupix.com';
      }
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: senha,
      );
      
      return response.user != null;
    } on AuthException catch (e) {
      logDebug('Erro de autenticação: ${e.message}');
      rethrow;
    } catch (e) {
      logDebug('Erro ao fazer login: $e');
      rethrow;
    }
  }
  
  Future<bool> register(
    String identificador, 
    String senha, {
    required String nome, 
    required String cpf, 
    required String telefone,
    bool isPessoaFisica = true,
  }) async {
    try {
      String email;
      if (identificador.contains('@')) {
        email = identificador;
      } else {
        email = '${identificador.replaceAll(RegExp(r'[^0-9]'), '')}@urubupix.com';
      }
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: senha,
        data: {
          'nome': nome,
          'cpf': cpf,
          'telefone': telefone,
          'tipo_pessoa': isPessoaFisica ? 'fisica' : 'juridica',
        },
      );
      
      if (response.user != null) {
        // Cria conta com saldo inicial
        await _supabase.from('accounts').insert({
          'user_id': response.user!.id,
          'balance': 30000.0,
        });
        
        // Cria perfil do usuário
        await _supabase.from('users').insert({
          'user_id': response.user!.id,
          'email': email,
          'nome': nome,
          'cpf': cpf,
          'telefone': telefone,
          'tipo_pessoa': isPessoaFisica ? 'fisica' : 'juridica',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        return true;
      } else {
        throw Exception('Não foi possível concluir o cadastro.');
      }
    } on AuthException catch (e) {
      logDebug('Erro ao registrar: ${e.message}');
      rethrow;
    } catch (e) {
      logDebug('Erro ao registrar usuário: $e');
      rethrow;
    }
  }
  
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Método para buscar histórico de cotações (últimos 7 dias)
  static Future<Map<String, List<MapEntry<DateTime, double>>>> getExchangeRateHistory() async {
    logDebug('Buscando histórico de cotações...');
    try {
      final now = DateTime.now();
      final Map<String, List<MapEntry<DateTime, double>>> history = {
        'USD': [],
        'EUR': [],
      };
      
      // Usa a função do Supabase para obter as cotações atuais
      final response = await Supabase.instance.client.functions.invoke('cotacoes', body: {});
      
      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;
        logDebug('Resposta da função cotacoes: $data');
        
        // Obtém as taxas atuais
        final dolarRate = double.tryParse(data['dolar']?.toString() ?? '0') ?? 0;
        final euroRate = double.tryParse(data['euro']?.toString() ?? '0') ?? 0;
        
        // Cria dados históricos simulados com base nas taxas atuais
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          
          // Adiciona uma pequena variação para simular flutuações
          final variation = 1.0 + (0.02 * (i / 7));
          
          if (dolarRate > 0) {
            final value = dolarRate * variation;
            history['USD']!.add(MapEntry(date, value));
          }
          
          if (euroRate > 0) {
            final value = euroRate * variation;
            history['EUR']!.add(MapEntry(date, value));
          }
        }
        
        // Ordena as entradas por data
        for (var entry in history.entries) {
          entry.value.sort((a, b) => a.key.compareTo(b.key));
          logDebug('Dados processados para ${entry.key}: ${entry.value.length} pontos');
        }
        
        return history;
      } else {
        throw Exception('Não foi possível buscar o histórico de cotações');
      }
    } catch (e, stackTrace) {
      logDebug('Erro ao buscar histórico: $e');
      logDebug('Stack trace: $stackTrace');
      
      // Retorna dados de exemplo em caso de erro
      try {
        final now = DateTime.now();
        final exampleData = {
          'USD': List.generate(7, (i) {
            final date = now.subtract(Duration(days: 6 - i));
            final value = 5.0 + (i * 0.1);
            logDebug('Exemplo USD: $date = $value');
            return MapEntry(date, value);
          }),
          'EUR': List.generate(7, (i) {
            final date = now.subtract(Duration(days: 6 - i));
            final value = 5.5 + (i * 0.08);
            logDebug('Exemplo EUR: $date = $value');
            return MapEntry(date, value);
          }),
        };
        logDebug('Retornando dados de exemplo');
        return exampleData;
      } catch (e) {
        logDebug('Erro ao gerar dados de exemplo: $e');
        rethrow;
      }
    }
  
  }
}
