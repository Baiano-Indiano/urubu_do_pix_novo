import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/biometric_service.dart';
import '../services/api_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../routes/custom_route.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _biometricService = BiometricService();
  bool _biometriaDisponivel = false;
  final TextEditingController _identificadorController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final maskCpf = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  bool _isLoading = false;
  bool _loginPorCpf = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _verificarBiometria();
  }

  @override
  void dispose() {
    _identificadorController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _verificarBiometria() async {
    final disponivel = await _biometricService.isBiometricAvailable();
    setState(() {
      _biometriaDisponivel = disponivel;
    });
  }

  Future<void> _autenticarComBiometria() async {
    final autenticado = await _biometricService.authenticate();
    if (autenticado && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // Remove o método _validarCredenciais antigo, pois não é mais necessário

  Future<void> _login() async {
    if (_isLoading) return;
    
    // Validações
    final identificador = _identificadorController.text.trim();
    final senha = _senhaController.text;
    
    // Validação do identificador (CPF ou E-mail)
    if (identificador.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe seu CPF ou E-mail')),
      );
      return;
    }
    
    if (_loginPorCpf) {
      if (!isValidCPF(identificador)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CPF inválido. Por favor, verifique os dados.')),
        );
        return;
      }
    } else {
      if (!isValidEmail(identificador)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail inválido. Por favor, verifique os dados.')),
        );
        return;
      }
    }
    
    // Validação da senha
    if (senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe sua senha')),
      );
      return;
    }
    
    if (senha.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A senha deve ter no mínimo 4 caracteres')),
      );
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final loginSucesso = await apiService.login(identificador, senha);
      
      if (!mounted) return;
      
      if (!loginSucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail/CPF ou senha incorretos'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      
      // Se chegou aqui, o login foi bem-sucedido
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login realizado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Aguarda um pouco para o usuário ver a mensagem antes de navegar
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      String mensagemErro = 'Erro ao fazer login. Tente novamente.';
      if (e is AuthException) {
        mensagemErro = e.message;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagemErro),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // Logo e Título
              Column(
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                              letterSpacing: 1.2,
                            ),
                            children: [
                              TextSpan(
                                text: 'URUBU',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              TextSpan(
                                text: ' DO PIX',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seu banco digital completo',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.7 * 255),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),

              // Formulário de login
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título do formulário
                      Text(
                        'Acesse sua conta',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Faça login para continuar',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.7 * 255),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Toggle CPF/Email
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildToggleButton(
                                'CPF',
                                _loginPorCpf,
                                () => setState(() {
                                  _loginPorCpf = true;
                                  _identificadorController.clear();
                                }),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildToggleButton(
                                'E-mail',
                                !_loginPorCpf,
                                () => setState(() {
                                  _loginPorCpf = false;
                                  _identificadorController.clear();
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo de CPF/E-mail
                      TextFormField(
                        controller: _identificadorController,
                        keyboardType: _loginPorCpf ? TextInputType.number : TextInputType.emailAddress,
                        inputFormatters: _loginPorCpf ? [maskCpf] : null,
                        decoration: InputDecoration(
                          labelText: _loginPorCpf ? 'CPF' : 'E-mail',
                          prefixIcon: Icon(
                            _loginPorCpf ? Icons.badge : Icons.email,
                            color: colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary.withValues(alpha: 0.5 * 255),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo de senha
                      TextFormField(
                        controller: _senhaController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(
                            Icons.lock,
                            color: colorScheme.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: colorScheme.primary,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary.withValues(alpha: 0.5 * 255),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botão de login
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Link para cadastro
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            SlideRightRoute(
                              page: const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Ainda não tem conta? Cadastre-se',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Biometria com animação
              if (_biometriaDisponivel) ...[
                const SizedBox(height: 32),
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary.withValues(alpha: 0.1 * 255),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: IconButton(
                          icon: Icon(
                            Icons.fingerprint,
                            size: 50,
                            color: colorScheme.primary,
                          ),
                          onPressed: _autenticarComBiometria,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entrar com biometria',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colorScheme.primary : theme.dividerColor,
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
