import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  static const String _keyBiometricEnabled = 'biometric_enabled';
  final _encryptionKey = encrypt.Key.fromLength(32);
  final _iv = encrypt.IV.fromLength(16);

  // Verifica se o dispositivo suporta biometria
  Future<bool> isBiometricAvailable() async {
    try {
      // No Windows, retorna false pois não há suporte nativo
      if (Platform.isWindows) return false;

      // Verifica se o hardware suporta biometria
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return false;

      // Lista os tipos de biometria disponíveis
      final List<BiometricType> availableBiometrics =
          await _auth.getAvailableBiometrics();

      return availableBiometrics.isNotEmpty;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Realiza a autenticação biométrica
  Future<bool> authenticate() async {
    try {
      if (!await isBiometricAvailable()) return false;

      return await _auth.authenticate(
        localizedReason: 'Autentique-se para acessar o aplicativo',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Verifica se a biometria está habilitada nas preferências
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    if (Platform.isWindows) {
      // No Windows, usa uma versão criptografada do SharedPreferences
      final encrypted = prefs.getString('${_keyBiometricEnabled}_encrypted');
      if (encrypted == null) return false;

      final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
      try {
        final decrypted = encrypter.decrypt64(encrypted, iv: _iv);
        return decrypted == 'true';
      } catch (_) {
        return false;
      }
    } else {
      return prefs.getBool(_keyBiometricEnabled) ?? false;
    }
  }

  // Habilita ou desabilita a biometria nas preferências
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    if (Platform.isWindows) {
      // No Windows, armazena de forma criptografada
      final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
      final encrypted = encrypter.encrypt(enabled.toString(), iv: _iv);
      await prefs.setString(
          '${_keyBiometricEnabled}_encrypted', encrypted.base64);
    } else {
      await prefs.setBool(_keyBiometricEnabled, enabled);
    }
  }
}
