import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'home_screen.dart';

import '../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  final TextEditingController _identificadorController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final maskCpf = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final maskPhone = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  String? _errorMessage;
  String? _cpfError, _telefoneError, _nomeError, _emailError;
  bool _isLoading = false;
  bool _cadastroPorCpf = true;

  void _register() async {
    setState(() {
      _cpfError = null;
      _telefoneError = null;
      _nomeError = null;
    });
    final identificador = _identificadorController.text.trim();
    final senha = _senhaController.text;
    final cpf = _cpfController.text.trim();
    final telefone = _telefoneController.text.trim();
    final nome = _nomeController.text.trim();
    String? errorMessage;
    if (_cadastroPorCpf) {
      if (!isValidCPF(identificador)) {
        errorMessage = 'Digite um CPF válido.';
      }
    } else {
      if (!isValidEmail(identificador)) {
        errorMessage = 'Digite um e-mail válido.';
      }
    }
    if (!isValidName(nome)) {
      _nomeError = 'Digite um nome válido (apenas letras e espaços, mínimo 3 letras).';
      errorMessage = 'Digite um nome válido.';
    }
    if (!isValidCPF(cpf)) {
      _cpfError = 'Digite um CPF válido.';
      errorMessage = 'Digite um CPF válido.';
    }
    if (!isValidPhoneBR(telefone)) {
      _telefoneError = 'Digite um telefone válido com DDD (ex: 11999999999).';
      errorMessage = 'Digite um telefone válido.';
    }
    if (senha.isEmpty || senha.length < 4) {
      errorMessage = 'A senha deve ter pelo menos 4 caracteres.';
    }

    setState(() {});
    if (errorMessage != null) {
      setState(() {
        _errorMessage = errorMessage;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final success = await ApiService().register(
        identificador,
        senha,
        nome: nome,
        cpf: cpf,
        telefone: telefone,
      );
      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
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
            content: Text('Este CPF já está cadastrado.'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro: \n${e.toString()}'),
          backgroundColor: Colors.red));
      setState(() {
        _emailError = 'Este e-mail já está cadastrado.';
      });
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
      appBar: AppBar(title: const Text('Cadastro')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Criar Conta',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              // Toggle entre CPF e E-mail
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('CPF'),
                    selected: _cadastroPorCpf,
                    onSelected: (v) {
                      setState(() {
                        _cadastroPorCpf = true;
                        _identificadorController.clear();
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('E-mail'),
                    selected: !_cadastroPorCpf,
                    onSelected: (v) {
                      setState(() {
                        _cadastroPorCpf = false;
                        _identificadorController.clear();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _identificadorController,
                inputFormatters: _cadastroPorCpf ? [maskCpf] : null,
                decoration: InputDecoration(
                  labelText: _cadastroPorCpf ? 'CPF' : 'E-mail',
                  border: const OutlineInputBorder(),
                  errorText: !_cadastroPorCpf ? _emailError : null,
                ),
                keyboardType: _cadastroPorCpf
                    ? TextInputType.number
                    : TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome completo',
                  border: const OutlineInputBorder(),
                  errorText: _nomeError,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _cpfController,
                inputFormatters: [maskCpf],
                decoration: InputDecoration(
                  labelText: 'CPF',
                  border: const OutlineInputBorder(),
                  errorText: _cpfError,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _telefoneController,
                inputFormatters: [maskPhone],
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  border: const OutlineInputBorder(),
                  errorText: _telefoneError,
                ),
                keyboardType: TextInputType.phone,
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
                  final enableRegister = !_isLoading &&
                      ((_cadastroPorCpf &&
                              id.replaceAll(RegExp(r'[^0-9]'), '').length ==
                                  11) ||
                          (!_cadastroPorCpf && isValidEmail(id))) &&
                      senha.length >= 4;
                  return ElevatedButton(
                    onPressed: enableRegister ? _register : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Cadastrar'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
