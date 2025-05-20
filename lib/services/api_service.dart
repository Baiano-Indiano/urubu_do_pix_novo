import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:io';

class ApiService {
  ApiService();

  // Adicione funções de autenticação e API aqui
  // Funções utilitárias de validação foram movidas para utils/validators.dart
  final supabase = Supabase.instance.client;

  // Login com CPF e senha (transforma CPF em e-mail)
  Future<bool> login(String identificador, String senha) async {
    try {
      String email;
      if (identificador.contains('@')) {
        email = identificador;
      } else {
        email =
            '${identificador.replaceAll(RegExp(r'[^0-9]'), '')}@urubupix.com';
      }
      final res =
          await supabase.auth.signInWithPassword(email: email, password: senha);
      return res.user != null;
    } on AuthException catch (e) {
      throw Exception('Não foi possível entrar. Verifique seu usuário e senha e tente novamente. Detalhes: ${e.message}');
    } catch (e) {
      throw Exception('Não foi possível entrar. Verifique seu usuário e senha e tente novamente. Detalhes: ${e.toString()}');
    }
  }

  // Registro com CPF e senha (transforma CPF em e-mail)
  Future<bool> register(String identificador, String senha, {required String nome, required String cpf, required String telefone}) async {
    try {
      String email;
      if (identificador.contains('@')) {
        email = identificador;
      } else {
        email = '${identificador.replaceAll(RegExp(r'[^0-9]'), '')}@urubupix.com';
      }
      final res = await supabase.auth.signUp(email: email, password: senha);
      if (res.user != null) {
        // Cria conta com saldo inicial
        await supabase.from('accounts').insert({
          'user_id': res.user!.id,
          'balance': 30000.0,
        });
        // Salva dados do perfil na tabela users
        await supabase.from('users').insert({
          'user_id': res.user!.id,
          'nome': nome,
          'cpf': cpf,
          'telefone': telefone,
          'email': email,
        });
        return true;
      } else {
        throw Exception('Não foi possível concluir o cadastro. Tente novamente mais tarde.');
      }
    } on AuthException catch (e) {
      if (e.message.contains('already registered') ||
          e.message.contains('already exists')) {
        throw Exception('Já existe uma conta cadastrada com este CPF.');
      } else {
        throw Exception('Não foi possível concluir o cadastro. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Ocorreu um erro ao cadastrar. Tente novamente. Detalhes: ${e.toString()}');
    }
  }

  bool get isLoggedIn => supabase.auth.currentUser != null;
  String? get usuarioAtual => supabase.auth.currentUser?.id;

  void logout() {
    supabase.auth.signOut();
  }

  // --- Cotação real via AwesomeAPI ---
  Future<Map<String, double>> fetchCotacoes() async {
    final response =
        await Supabase.instance.client.functions.invoke('cotacoes', body: {});
    if (response.data != null) {
      final data = response.data as Map<String, dynamic>;
      return {
        'dolar': double.parse(data['dolar'].toString()),
        'euro': double.parse(data['euro'].toString()),
      };
    } else {
      throw Exception('Não foi possível buscar as cotações no momento.');
    }
  }

  // --- Saldo/histórico por usuário autenticado ---
  Future<double> fetchSaldo() async {
    final userId = usuarioAtual;
    if (userId == null) throw Exception('Você precisa estar logado para acessar esta funcionalidade.');
    final data = await supabase
        .from('accounts')
        .select('balance')
        .eq('user_id', userId)
        .single();
    return (data['balance'] as num?)?.toDouble() ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> fetchHistorico() async {
    final userId = usuarioAtual;
    if (userId == null) throw Exception('Você precisa estar logado para acessar esta funcionalidade.');
    final data = await supabase
        .from('transfers')
        .select()
        .eq('user_id', userId)
        .order('data', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<String?> uploadProfilePhoto(File file, String userId) async {
    final storage = supabase.storage.from('profile-photos');
    final filePath = 'user_$userId/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    await storage.upload(filePath, file);
    final url = storage.getPublicUrl(filePath);
    return url;
  }

  Future<void> updateProfilePhotoUrl(String userId, String url) async {
    await supabase.from('users').update({'foto': url}).eq('user_id', userId);
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final data = await supabase.from('users').select().eq('user_id', userId).maybeSingle();
    return data;
  }

  Future<void> updateUserProfile({required String userId, String? nome, String? telefone, String? foto}) async {
    final updateData = <String, dynamic>{};
    if (nome != null) updateData['nome'] = nome;
    if (telefone != null) updateData['telefone'] = telefone;
    if (foto != null) updateData['foto'] = foto;
    if (updateData.isNotEmpty) {
      await supabase.from('users').update(updateData).eq('user_id', userId);
    }
  }

  Future<void> registrarTransferencia(String destinatario, double valor,
      {String? moeda, double? valorOriginal}) async {
    final userId = usuarioAtual;
    if (userId == null) throw Exception('Você precisa estar logado para acessar esta funcionalidade.');
    final accountData = await supabase
        .from('accounts')
        .select('balance')
        .eq('user_id', userId)
        .single();
    final currentBalance = (accountData['balance'] as num?)?.toDouble() ?? 0.0;
    if (currentBalance < valor) throw Exception('Saldo insuficiente para realizar esta operação.');
    await supabase
        .from('accounts')
        .update({'balance': currentBalance - valor}).eq('user_id', userId);
    await supabase.from('transfers').insert({
      'user_id': userId,
      'destinatario': destinatario,
      'valor': valor,
      'moeda': moeda,
      'valor_original': valorOriginal,
      'data': DateTime.now().toString().substring(0, 16),
    });
  }
}
