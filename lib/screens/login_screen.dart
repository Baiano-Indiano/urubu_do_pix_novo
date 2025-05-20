import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'home_screen.dart';
import 'register_screen.dart';

import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _identificadorController.addListener(() => setState(() {}));
    _senhaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _identificadorController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  final TextEditingController _identificadorController =
      TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final maskCpf = MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  bool _isLoading = false;
  String? _errorMessage;
  bool _loginPorCpf = true;

  void _login(BuildContext context) async {
    setState(() {
      _errorMessage = null;
    });
    final identificador = _identificadorController.text.trim();
    final senha = _senhaController.text;
    String? errorMessage;
    if (_loginPorCpf) {
      if (!isValidCPF(identificador)) {
        errorMessage = 'Digite um CPF válido.';
      }
    } else {
      if (!isValidEmail(identificador)) {
        errorMessage = 'Digite um e-mail válido.';
      }
    }
    if (senha.isEmpty || senha.length < 4) {
      errorMessage = 'A senha deve ter pelo menos 4 caracteres.';
    }
    if (errorMessage != null) {
      setState(() {
        _errorMessage = errorMessage;
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final api = ApiService();
      final success = await api.login(identificador, senha);
      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Login realizado com sucesso!'),
            backgroundColor: Colors.green));
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('CPF ou senha inválidos'),
            backgroundColor: Colors.red));
        setState(() {
          _errorMessage = 'CPF ou senha inválidos.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Urubu Pix',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              // Toggle entre CPF e E-mail
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('CPF'),
                    selected: _loginPorCpf,
                    onSelected: (v) {
                      setState(() {
                        _loginPorCpf = true;
                        _identificadorController.clear();
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('E-mail'),
                    selected: !_loginPorCpf,
                    onSelected: (v) {
                      setState(() {
                        _loginPorCpf = false;
                        _identificadorController.clear();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _identificadorController,
                inputFormatters: _loginPorCpf ? [maskCpf] : null,
                decoration: InputDecoration(
                  labelText: _loginPorCpf ? 'CPF' : 'E-mail',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: _loginPorCpf
                    ? TextInputType.number
                    : TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _senhaController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null) ...[
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
              ],
              Builder(
                builder: (context) {
                  final id = _identificadorController.text.trim();
                  final senha = _senhaController.text.trim();
                  final enableLogin = !_isLoading &&
                      ((_loginPorCpf &&
                              id.replaceAll(RegExp(r'[^0-9]'), '').length ==
                                  11) ||
                          (!_loginPorCpf && _isValidEmail(id))) &&
                      senha.length >= 4;
                  return ElevatedButton(
                    onPressed: enableLogin ? () => _login(context) : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Entrar'),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => RegisterScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: const Text('Não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
