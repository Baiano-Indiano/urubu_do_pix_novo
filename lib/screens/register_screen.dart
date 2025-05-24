import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart' show MaskTextInputFormatter, MaskAutoCompletionType;
import '../services/api_service.dart';
import '../utils/validators.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para os campos de texto
  final TextEditingController _identificadorController =
      TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();

  // Formatadores para campos com máscara
  final maskCpf = MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final maskCnpj = MaskTextInputFormatter(
      mask: '##.###.###/####-##', filter: {"#": RegExp(r'[0-9]')});
  final maskPhone = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  // Variáveis de estado
  String? _errorMessage;
  String? _cpfError,
      _telefoneError,
      _nomeError,
      _emailError,
      _senhaError,
      _confirmarSenhaError;
  bool _isLoading = false;
  bool _cadastroPorCpf = true;
  bool _isPessoaFisica = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _aceitouTermos = false;

  // Chave do formulário para validação
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Adiciona listeners para validação em tempo real
    _identificadorController.addListener(_validateIdentificador);
    _senhaController.addListener(_validateSenha);
    _confirmarSenhaController.addListener(_validateConfirmarSenha);
    _nomeController.addListener(_validateNome);
    _cpfController.addListener(_validateCpf);
    _telefoneController.addListener(_validateTelefone);
  }

  @override
  void dispose() {
    // Libera recursos
    _identificadorController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  // Validações em tempo real
  void _validateIdentificador() {
    setState(() {
      if (_identificadorController.text.isEmpty) {
        _emailError = null;
        return;
      }

      final text = _identificadorController.text.trim();
      if (_cadastroPorCpf) {
        if (_isPessoaFisica) {
          if (!isValidCPF(text)) {
            _emailError = 'CPF inválido';
          } else {
            _emailError = null;
          }
        } else {
          if (!isValidCNPJ(text)) {
            _emailError = 'CNPJ inválido';
          } else {
            _emailError = null;
          }
        }
      } else {
        if (!isValidEmail(text)) {
          _emailError = 'E-mail inválido';
        } else {
          _emailError = null;
        }
      }
    });
  }

  void _validateSenha() {
    setState(() {
      if (_senhaController.text.isEmpty) {
        _senhaError = null;
        return;
      }

      if (!isStrongPassword(_senhaController.text)) {
        _senhaError =
            'A senha deve ter pelo menos 8 caracteres, incluindo letras maiúsculas, minúsculas, números e símbolos';
      } else {
        _senhaError = null;
      }

      // Valida a confirmação de senha se já foi preenchida
      if (_confirmarSenhaController.text.isNotEmpty) {
        _validateConfirmarSenha();
      }
    });
  }

  void _validateConfirmarSenha() {
    setState(() {
      if (_confirmarSenhaController.text.isEmpty) {
        _confirmarSenhaError = null;
        return;
      }

      if (_confirmarSenhaController.text != _senhaController.text) {
        _confirmarSenhaError = 'As senhas não coincidem';
      } else {
        _confirmarSenhaError = null;
      }
    });
  }

  void _validateNome() {
    setState(() {
      if (_nomeController.text.isEmpty) {
        _nomeError = null;
        return;
      }

      if (!isValidName(_nomeController.text)) {
        _nomeError = 'Digite nome e sobrenome válidos';
      } else {
        _nomeError = null;
      }
    });
  }

  void _validateCpf() {
    setState(() {
      if (_cpfController.text.isEmpty) {
        _cpfError = null;
        return;
      }

      if (!isValidCPF(_cpfController.text)) {
        _cpfError = 'CPF inválido';
      } else {
        _cpfError = null;
      }
    });
  }

  void _validateTelefone() {
    setState(() {
      if (_telefoneController.text.isEmpty) {
        _telefoneError = null;
        return;
      }

      final phone = _telefoneController.text;
      if (phone.isEmpty) {
        _telefoneError = null;
        return;
      }
      
      final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (cleaned.length != 11) {
        _telefoneError = 'O número deve ter 11 dígitos (DDD + 9 + número)';
      } else if (cleaned[2] != '9') {
        _telefoneError = 'Número de celular deve começar com 9 após o DDD';
      } else if (RegExp(r'^(\d)\1+$').hasMatch(cleaned.substring(2))) {
        _telefoneError = 'Número de telefone inválido';
      } else {
        _telefoneError = null;
      }
    });
  }

  void _register() async {
    // Valida todos os campos antes de enviar
    _validateIdentificador();
    _validateNome();
    _validateCpf();
    _validateTelefone();
    _validateSenha();
    _validateConfirmarSenha();

    // Verifica se há erros de validação
    if (_emailError != null ||
        _nomeError != null ||
        _cpfError != null ||
        _telefoneError != null ||
        _senhaError != null ||
        _confirmarSenhaError != null ||
        !_aceitouTermos) {
      setState(() {
        _errorMessage = 'Por favor, corrija os erros nos campos destacados.';
        if (!_aceitouTermos) {
          _errorMessage = 'É necessário aceitar os termos e condições.';
        }
      });
      return;
    }

    final identificador = _identificadorController.text.trim();
    final senha = _senhaController.text;
    final cpf = _cpfController.text.trim();
    final telefone = _telefoneController.text.trim();
    final nome = _nomeController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Mostra um indicador de progresso com mensagem
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Processando seu cadastro...'),
                const SizedBox(height: 8),
                Text('Aguarde enquanto verificamos seus dados',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          );
        },
      );

      // Realiza o cadastro
      final success = await ApiService().register(
        identificador,
        senha,
        nome: nome,
        cpf: cpf,
        telefone: telefone,
        isPessoaFisica: _isPessoaFisica,
      );

      // Fecha o diálogo de progresso
      if (mounted && context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      if (success) {
        if (!context.mounted) return;
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        if (!context.mounted) return;

        // Mostra mensagem de sucesso
        scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ));

        // Redireciona para a tela inicial após um breve atraso
        await Future.delayed(const Duration(milliseconds: 700));
        if (!context.mounted) return;

        navigator.pushReplacement(
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
        if (!context.mounted) return;
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        if (!context.mounted) return;

        // Mostra mensagem de erro
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(_cadastroPorCpf
              ? (_isPessoaFisica
                  ? 'Este CPF já está cadastrado.'
                  : 'Este CNPJ já está cadastrado.')
              : 'Este e-mail já está cadastrado.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ));
      }
    } catch (e) {
      // Fecha o diálogo de progresso se estiver aberto
      if (mounted && context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;
      if (!context.mounted) return;

      // Mostra mensagem de erro detalhada
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      if (!context.mounted) return;
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Erro ao processar o cadastro:'),
            const SizedBox(height: 4),
            Text(e.toString(), style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ));

      setState(() {
        if (_cadastroPorCpf) {
          _emailError = _isPessoaFisica
              ? 'Este CPF já está cadastrado ou é inválido.'
              : 'Este CNPJ já está cadastrado ou é inválido.';
        } else {
          _emailError = 'Este e-mail já está cadastrado.';
        }
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
      appBar: AppBar(
        title: const Text('Cadastro'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  const Center(
                    child: Text(
                      'Crie sua conta',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Preencha os campos abaixo para criar sua conta',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tipo de cadastro
                  const Text('Tipo de cadastro:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('CPF/CNPJ'),
                          selected: _cadastroPorCpf,
                          onSelected: (v) {
                            setState(() {
                              _cadastroPorCpf = true;
                              _identificadorController.clear();
                              _emailError = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('E-mail'),
                          selected: !_cadastroPorCpf,
                          onSelected: (v) {
                            setState(() {
                              _cadastroPorCpf = false;
                              _identificadorController.clear();
                              _emailError = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Tipo de pessoa (apenas se for CPF/CNPJ)
                  if (_cadastroPorCpf) ...[
                    const SizedBox(height: 16),
                    const Text('Tipo de pessoa:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Pessoa Física'),
                            selected: _isPessoaFisica,
                            onSelected: (v) {
                              setState(() {
                                _isPessoaFisica = true;
                                _identificadorController.clear();
                                _emailError = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Pessoa Jurídica'),
                            selected: !_isPessoaFisica,
                            onSelected: (v) {
                              setState(() {
                                _isPessoaFisica = false;
                                _identificadorController.clear();
                                _emailError = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Campo de identificador (CPF/CNPJ ou E-mail)
                  TextField(
                    controller: _identificadorController,
                    inputFormatters: _cadastroPorCpf
                        ? [_isPessoaFisica ? maskCpf : maskCnpj]
                        : null,
                    decoration: InputDecoration(
                      labelText: _cadastroPorCpf
                          ? (_isPessoaFisica ? 'CPF' : 'CNPJ')
                          : 'E-mail',
                      prefixIcon: Icon(_cadastroPorCpf
                          ? Icons.badge_outlined
                          : Icons.email_outlined),
                      border: const OutlineInputBorder(),
                      errorText: _emailError,
                      hintText: _cadastroPorCpf
                          ? (_isPessoaFisica
                              ? '000.000.000-00'
                              : '00.000.000/0000-00')
                          : 'seu.email@exemplo.com',
                    ),
                    keyboardType: _cadastroPorCpf
                        ? TextInputType.number
                        : TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Nome completo
                  TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      labelText: 'Nome completo',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                      errorText: _nomeError,
                      hintText: 'Digite seu nome completo',
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // CPF
                  TextField(
                    controller: _cpfController,
                    inputFormatters: [maskCpf],
                    decoration: InputDecoration(
                      labelText: 'CPF',
                      prefixIcon: const Icon(Icons.credit_card_outlined),
                      border: const OutlineInputBorder(),
                      errorText: _cpfError,
                      hintText: '000.000.000-00',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Telefone
                  TextField(
                    controller: _telefoneController,
                    inputFormatters: [maskPhone],
                    decoration: InputDecoration(
                      labelText: 'Telefone',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: const OutlineInputBorder(),
                      errorText: _telefoneError,
                      hintText: '(00) 00000-0000',
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Senha
                  TextField(
                    controller: _senhaController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      errorText: _senhaError,
                      hintText: 'Crie uma senha forte',
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  if (_senhaError == null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'A senha deve conter letras maiúsculas, minúsculas, números e símbolos',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Confirmar senha
                  TextField(
                    controller: _confirmarSenhaController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      errorText: _confirmarSenhaError,
                      hintText: 'Digite a senha novamente',
                    ),
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),

                  // Termos e condições
                  Row(
                    children: [
                      Checkbox(
                        value: _aceitouTermos,
                        onChanged: (value) {
                          setState(() {
                            _aceitouTermos = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _aceitouTermos = !_aceitouTermos;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.grey[800]),
                              children: [
                                const TextSpan(text: 'Li e concordo com os '),
                                TextSpan(
                                  text: 'Termos de Uso',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: ' e '),
                                TextSpan(
                                  text: 'Política de Privacidade',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mensagem de erro
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Botão de cadastro
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('CRIAR CONTA',
                              style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Link para login
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.grey[800]),
                          children: [
                            const TextSpan(text: 'Já tem uma conta? '),
                            TextSpan(
                              text: 'Faça login',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
