import 'package:flutter/material.dart';
import '../services/biometric_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _biometricService = BiometricService();
  bool _biometriaDisponivel = false;
  bool _biometriaHabilitada = false;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    final disponivel = await _biometricService.isBiometricAvailable();
    final habilitada = await _biometricService.isBiometricEnabled();

    if (mounted) {
      setState(() {
        _biometriaDisponivel = disponivel;
        _biometriaHabilitada = habilitada;
        _carregando = false;
      });
    }
  }

  Future<void> _toggleBiometria(bool value) async {
    try {
      if (value) {
        // Tenta autenticar antes de habilitar
        final autenticado = await _biometricService.authenticate();
        if (!autenticado) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Falha na autenticação biométrica'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      await _biometricService.setBiometricEnabled(value);
      if (mounted) {
        setState(() {
          _biometriaHabilitada = value;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? 'Biometria habilitada com sucesso'
              : 'Biometria desabilitada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao configurar biometria'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Segurança',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_biometriaDisponivel)
                  SwitchListTile(
                    title: const Text('Usar biometria'),
                    subtitle: const Text(
                      'Use sua digital ou reconhecimento facial para fazer login',
                    ),
                    value: _biometriaHabilitada,
                    onChanged: _toggleBiometria,
                  )
                else
                  ListTile(
                    title: const Text('Biometria não disponível'),
                    subtitle: const Text(
                      'Seu dispositivo não suporta autenticação biométrica',
                    ),
                    leading: const Icon(Icons.fingerprint_outlined),
                  ),
                const Divider(),
              ],
            ),
    );
  }
}
