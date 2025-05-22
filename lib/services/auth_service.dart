import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _error;
  User? _currentUser;

  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;

  AuthService() {
    // Inicializa com o usuário atual se existir
    _currentUser = _supabase.auth.currentUser;
    
    // Escuta mudanças no estado de autenticação
    _supabase.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  // Registra um novo usuário
  Future<bool> register({
    required String email,
    required String password,
    required String nome,
    required String cpf,
    required String telefone,
    bool isPessoaFisica = true,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 1. Registrar o usuário no Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nome': nome,
          'cpf': cpf,
          'telefone': telefone,
          'tipo_pessoa': isPessoaFisica ? 'fisica' : 'juridica',
        },
      );

      if (authResponse.user == null) {
        throw 'Falha ao criar usuário';
      }

      final userId = authResponse.user!.id;

      // 2. Criar conta com saldo inicial
      await _createUserAccount(userId);
      
      // 3. Criar perfil do usuário
      await _createUserProfile(
        userId: userId,
        email: email,
        nome: nome,
        cpf: cpf,
        telefone: telefone,
        isPessoaFisica: isPessoaFisica,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Cria uma conta para o usuário
  Future<void> _createUserAccount(String userId) async {
    try {
      await _supabase.from('accounts').insert({
        'user_id': userId,
        'balance': 30000.0,
      });
    } catch (e) {
      // Se falhar ao criar a conta, tenta novamente
      await _supabase.from('accounts').upsert({
        'user_id': userId,
        'balance': 30000.0,
      }).eq('user_id', userId);
    }
  }

  // Cria o perfil do usuário
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String nome,
    required String cpf,
    required String telefone,
    bool isPessoaFisica = true,
  }) async {
    try {
      await _supabase.from('users').upsert({
        'user_id': userId,
        'email': email,
        'nome': nome,
        'cpf': cpf,
        'telefone': telefone,
        'tipo_pessoa': isPessoaFisica ? 'fisica' : 'juridica',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Se falhar, tenta novamente
      await Future.delayed(const Duration(seconds: 1));
      await _supabase.from('users').upsert({
        'user_id': userId,
        'email': email,
        'nome': nome,
        'cpf': cpf,
        'telefone': telefone,
        'tipo_pessoa': isPessoaFisica ? 'fisica' : 'juridica',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);
    }
  }

  // Faz login
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Faz logout
  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.auth.signOut();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Alias para compatibilidade com código existente
  Future<void> logout() => signOut();

  // Verifica se o usuário está autenticado
  Future<bool> checkAuth() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        _currentUser = _supabase.auth.currentUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Limpa os erros
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
