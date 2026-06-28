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
  final String dni;
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
    return LoginResponse(
      token: json['token'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      dni: json['dni'] as String? ?? '',
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : DateTime.now(),
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
        'dni': dni,
        'role': role,
      };
}
