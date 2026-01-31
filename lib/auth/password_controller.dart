// password_controller.dart
import 'package:flutter/material.dart';

class PasswordController extends ChangeNotifier {
  bool _obscureText = true;

  bool get obscureText => _obscureText;

  void toggleVisibility() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}