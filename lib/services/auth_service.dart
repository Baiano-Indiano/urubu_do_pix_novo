import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;

  void login(String userId) {
    _isAuthenticated = true;
    _userId = userId;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userId = null;
    notifyListeners();
  }
}
