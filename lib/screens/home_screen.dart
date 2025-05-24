import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/saldo_card.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'cotation_screen.dart';
import 'transfer_screen.dart';
import 'settings_screen.dart';
import '../services/auth_service.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Tela inicial do aplicativo que exibe o saldo e opções principais
class _HomeScreenState extends State<HomeScreen> {
  double _saldo = 0.0;
  bool _isLoading = true;
  String? _error;
  bool _saldoVisivel = true;
  String _nomeUsuario = 'Usuário';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchSaldo();
    _loadUserProfile();
  }

  /// Carrega o perfil do usuário
  Future<void> _loadUserProfile() async {
    // Aqui você pode buscar o nome e avatar do usuário do perfil/SharedPreferences/API
    setState(() {
      _nomeUsuario = 'Usuário Exemplo';
      _avatarUrl = null; // ou URL da foto
    });
  }

  /// Exibe uma mensagem de sucesso
  void _showSuccessSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  /// Busca o saldo do usuário da API
  Future<void> _fetchSaldo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final saldo = await ApiService().fetchSaldo();
      if (mounted) {
        setState(() {
          _saldo = saldo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao buscar saldo';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urubu Pix'),
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saldo disponível',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SaldoCard(
              saldo: _saldo,
              visivel: _saldoVisivel,
              isLoading: _isLoading,
              error: _error,
              onToggleVisibilidade: () {
                setState(() {
                  _saldoVisivel = !_saldoVisivel;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF20232A)),
            accountEmail: const Text(''),
            accountName: Text(
              _nomeUsuario,
              style: const TextStyle(color: Colors.white),
            ),
            currentAccountPicture: _avatarUrl != null
                ? CircleAvatar(backgroundImage: NetworkImage(_avatarUrl!))
                : const CircleAvatar(child: Icon(Icons.person, size: 32)),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Histórico',
            onTap: _navigateToDashboard,
          ),
          _buildThemeToggleItem(),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Perfil',
            onTap: () => _navigateTo('/profile'),
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Configurações',
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          _buildLanguageItem(),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Sair',
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleItem() {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('Tema'),
      onTap: () {
        final theme = Theme.of(context).brightness;
        final appState = MyAppState.of(context);
        if (appState != null) {
          appState.setThemeMode(
            theme == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
          );
        }
      },
    );
  }

  Widget _buildLanguageItem() {
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('Idioma: Português/Inglês'),
      onTap: () {
        final locale = Localizations.localeOf(context).languageCode == 'pt'
            ? const Locale('en')
            : const Locale('pt');
        MyApp.setLocale(context, locale);
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            text: 'Transferir',
            onPressed: _navigateToTransfer,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            text: 'Cotação',
            onPressed: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const CotationScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  Future<void> _navigateToDashboard() async {
    Navigator.pop(context); // Fecha o drawer
    final api = ApiService();
    try {
      final saldo = await api.fetchSaldo();
      final historico = await api.fetchHistorico();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            saldo: saldo,
            historico: historico,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content:
              const Text('Você precisa estar logado para acessar o histórico.'),
          actions: [
            TextButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _navigateToLogin();
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _navigateToTransfer() async {
    if (!context.mounted) return;
    final navigator = Navigator.of(context);
    if (!context.mounted) return;

    final result = await navigator.push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TransferScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    if (!context.mounted) return;
    await _fetchSaldo(); // Atualiza o saldo após retornar
    if (result == true && context.mounted) {
      _showSuccessSnackbar('Transferência realizada com sucesso!');
    }
  }

  void _navigateTo(String route) {
    if (!context.mounted) return;
    final navigator = Navigator.of(context);
    if (!context.mounted) return;

    navigator.pop(); // Fecha o drawer
    if (!context.mounted) return;
    navigator.pushNamed(route);
  }

  void _navigateToLogin() {
    if (!context.mounted) return;
    final navigator = Navigator.of(context);
    if (!context.mounted) return;

    navigator.pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _logout() async {
    if (!context.mounted) return;
    final navigator = Navigator.of(context);
    if (!context.mounted) return;

    navigator.pop(); // Fecha o drawer
    if (!context.mounted) return;

    await context.read<AuthService>().logout();
    if (!context.mounted) return;

    _navigateToLogin();
  }
}
