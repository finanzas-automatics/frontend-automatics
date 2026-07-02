import 'dart:convert';
import 'package:flutter/cupertino.dart';

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class LoginResponse {
  final String token;
  final String name;
  final String email;
  final String role;
  final String dni; // Lo usamos para guardar el DNI real
  final DateTime expiresAt;

  LoginResponse({
    required this.token,
    required this.name,
    required this.email,
    required this.role,
    required this.dni,
    required this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final tokenString = json['data'] as String? ?? json['token'] as String? ?? '';

    if (tokenString.isNotEmpty && tokenString.split('.').length == 3) {
      try {
        final parts = tokenString.split('.');
        final payloadString = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        final payloadMap = jsonDecode(payloadString);

        debugPrint('CONTENIDO DEL JWT: $payloadMap');

        // Búsqueda del Nombre
        final extractedName = payloadMap['nombres'] ??
            payloadMap['name'] ??
            payloadMap['unique_name'] ??
            payloadMap['given_name'] ??
            'Usuario Desconocido';

        // ✅ AHORA PRIORIZAMOS EL DNI REAL QUE MANDA C#
        final extractedId = payloadMap['dni']?.toString() ??
            payloadMap['sub']?.toString() ??
            payloadMap['nameid']?.toString() ??
            payloadMap['id']?.toString() ??
            '00000000';

        return LoginResponse(
          token: tokenString,
          name: extractedName,
          email: payloadMap['email'] ?? 'Sin correo',
          role: 'Asesor',
          dni: extractedId, // Aquí se guarda el DNI
          expiresAt: payloadMap['exp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(payloadMap['exp'] * 1000)
              : DateTime.now().add(const Duration(hours: 1)),
        );
      } catch (e) {
        debugPrint('Error decodificando JWT: $e');
      }
    }

    return LoginResponse(
      token: tokenString,
      name: 'Usuario',
      email: 'correo@ejemplo.com',
      role: 'Asesor',
      dni: '00000000',
      expiresAt: DateTime.now(),
    );
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String dni;
  final String role;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.dni,
    this.role = 'Asesor Senior de Crédito',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'dni': dni, // ✅ ESTE ES EL DNI QUE ENVÍA FLUTTER AL REGISTRAR
    'role': role,
  };
}