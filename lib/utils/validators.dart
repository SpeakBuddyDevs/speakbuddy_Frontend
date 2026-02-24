import 'package:flutter/material.dart';

/// Utilidades de validación para formularios
class FormValidators {
  /// Valida un email
  /// Retorna null si es válido, o un mensaje de error si no lo es
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your email';
    }
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim());
    return ok ? null : 'Invalid email';
  }

  /// Valida una contraseña con longitud mínima
  /// Retorna null si es válido, o un mensaje de error si no lo es
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    }
    if (value.length < minLength) {
      return 'Minimum $minLength characters';
    }
    return null;
  }

  /// Valida que una contraseña no esté vacía (solo requerido)
  /// Retorna null si es válido, o un mensaje de error si no lo es
  static String? validatePasswordRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    }
    return null;
  }

  /// Valida un nombre con longitud mínima
  /// Retorna null si es válido, o un mensaje de error si no lo es
  static String? validateName(String? value, {int minLength = 3}) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your name';
    }
    if (value.trim().length < minLength) {
      return 'Enter your name';
    }
    return null;
  }

  /// Valida que un nombre no esté vacío (solo requerido)
  /// Retorna null si es válido, o un mensaje de error si no lo es
  static String? validateNameRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your name';
    }
    return null;
  }

  /// Valida que dos contraseñas coincidan
  /// Retorna null si es válido, o un mensaje de error si no lo es
  static String? validatePasswordMatch(String? value, String? otherPassword) {
    if (value == null || value.isEmpty) {
      return 'Repeat the password';
    }
    if (value != otherPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Valida que un valor no esté vacío (validación genérica)
  /// Retorna null si es válido, o un mensaje de error si no lo es
  static String? validateRequired(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    return null;
  }

  /// Valida el estado de un formulario
  /// 
  /// Verifica si el formulario asociado a la GlobalKey es válido.
  /// Retorna true si el formulario es válido, false en caso contrario.
  /// Maneja casos donde formKey o currentState pueden ser null.
  static bool isFormValid(GlobalKey<FormState>? formKey) {
    if (formKey == null) return false;
    final formState = formKey.currentState;
    if (formState == null) return false;
    try {
      return formState.validate();
    } catch (e) {
      return false;
    }
  }
}

