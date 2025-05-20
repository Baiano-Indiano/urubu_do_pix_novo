import 'package:flutter/material.dart';
import 'package:urubu_pix/main.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import '../utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 11) text = text.substring(0, 11);
    String formatted = text;
    if (text.length >= 2) {
      formatted = '(${text.substring(0, 2)}';
      if (text.length >= 7) {
        formatted += ') ${text.substring(2, 7)}-${text.substring(7)}';
      } else if (text.length > 2) {
        formatted += ') ${text.substring(2)}';
      }
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _maskCpf(String cpf) {
    final clean = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length != 11) return cpf;
    return '${clean.substring(0, 3)}.***.***-${clean.substring(9)}';
  }

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  String? _fotoPath;
  String? _fotoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = ApiService().usuarioAtual;
    if (userId != null) {
      final dados = await ApiService().getUserProfile(userId);
      if (dados != null) {
        _nomeController.text = dados['nome'] ?? '';
        _telefoneController.text = dados['telefone'] ?? '';
        _fotoUrl = dados['foto'];
        _emailController.text = dados['email'] ?? '';
      }
    }
    // Carrega e mantém local (caso queira fallback offline)
    _emailController.text = prefs.getString('profile_email') ?? '';
    _fotoPath = prefs.getString('profile_foto');
    _isLoading = false;
    setState(() {});
  }

  String? _nomeError, _emailError, _telefoneError;

  Future<void> _saveProfile() async {
    setState(() {
      _nomeError = null;
      _emailError = null;
      _telefoneError = null;
    });
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final telefone = _telefoneController.text.trim();
    bool hasError = false;
    if (nome.isEmpty) {
      _nomeError = 'O nome é obrigatório.';
      hasError = true;
    } else if (!isValidName(nome)) {
      _nomeError = 'Nome inválido (apenas letras e espaços, mínimo 3 letras).';
      hasError = true;
    }
    if (!isValidEmail(email)) {
      _emailError = 'E-mail inválido.';
      hasError = true;
    } else if (await isEmailRegistered(email)) {
      _emailError = 'E-mail já cadastrado.';
      hasError = true;
    }
    if (!isValidPhoneBR(telefone)) {
      _telefoneError = 'Telefone inválido (use DDD, ex: 11999999999).';
      hasError = true;
    }
    setState(() {});
    if (hasError) return;
    try {
      // Atualiza localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_nome', nome);
      await prefs.setString('profile_email', email);
      await prefs.setString('profile_telefone', telefone);
      if (_fotoPath != null) await prefs.setString('profile_foto', _fotoPath!);
      // Atualiza no backend Supabase
      final userId = ApiService().usuarioAtual;
      if (userId != null) {
        await ApiService().updateUserProfile(userId: userId, nome: nome, telefone: telefone, foto: _fotoUrl);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil salvo com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar perfil: $e')),
        );
      }
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) {
      setState(() {
        _fotoPath = img.path;
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (img != null) {
      setState(() {
        _fotoPath = img.path;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final userId = ApiService().usuarioAtual;
    if (userId == null) return;
    final file = File(picked.path);
    setState(() => _isLoading = true);
    try {
      final url = await ApiService().uploadProfilePhoto(file, userId);
      if (url != null) {
        await ApiService().updateProfilePhotoUrl(userId, url);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_foto_url', url);
        setState(() {
          _fotoUrl = url;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto atualizada!')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao enviar foto: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cpf = ApiService().usuarioAtual ?? '--';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _fotoUrl != null
                            ? NetworkImage(_fotoUrl!)
                            : (_fotoPath != null ? FileImage(File(_fotoPath!)) : null) as ImageProvider<Object>?,
                        child: (_fotoUrl == null && _fotoPath == null)
                            ? const Icon(Icons.person, size: 48)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: _pickAndUploadPhoto,
                            ),
                            IconButton(
                              icon: const Icon(Icons.photo_camera),
                              tooltip: 'Tirar foto',
                              onPressed: _takePhoto,
                            ),
                            IconButton(
                              icon: const Icon(Icons.photo_library),
                              tooltip: 'Selecionar da galeria',
                              onPressed: _pickPhoto,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('CPF:  ${_maskCpf(cpf)}'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      border: const OutlineInputBorder(),
                      errorText: _nomeError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: const OutlineInputBorder(),
                      errorText: _emailError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _telefoneController,
                    decoration: InputDecoration(
                      labelText: 'Telefone',
                      border: const OutlineInputBorder(),
                      errorText: _telefoneError,
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _TelefoneInputFormatter(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar'),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.color_lens),
                      const SizedBox(width: 10),
                      const Text('Tema:'),
                      const SizedBox(width: 10),
                      DropdownButton<ThemeMode>(
                        value: _getCurrentThemeMode(context),
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('Sistema'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Claro'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Escuro'),
                          ),
                        ],
                        onChanged: (mode) {
                          if (mode != null) {
                            final state = _getAppState(context);
                            state?.setThemeMode(mode);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  // Função de editar senha (fictícia)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Função de editar senha em breve!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }
              },
              icon: const Icon(Icons.lock),
              label: const Text('Editar senha'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                // Logout real
                ApiService().logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sair da conta'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

// Helpers para pegar e definir o tema dinâmico
MyAppState? _getAppState(BuildContext context) {
  return context.findAncestorStateOfType<MyAppState>();
}

ThemeMode _getCurrentThemeMode(BuildContext context) {
  final state = _getAppState(context);
  return state?.themeMode ?? ThemeMode.system;
}
