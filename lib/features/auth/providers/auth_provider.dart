import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/api/api_client.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(secureStorageProvider),
  );
});


final currentUserIdProvider = FutureProvider<int>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final token = await storage.read(key: 'jwt_token');
  if (token == null) return 0;

  final decoded = JwtDecoder.decode(token);
  final sub = decoded['sub'];
  return int.tryParse(sub.toString()) ?? 0;
});

class AuthState {
  final bool isLoading;
  final String? error;
  final LoginResponse? user;

  AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    LoginResponse? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._repository, this._storage) : super(AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.login(LoginRequest(email: email, password: password));

      if (result.success && result.data != null) {
        // Ponemos el guardado del token en un try/catch interno para que no crashee la app web
        try {
          await _storage.write(key: 'jwt_token', value: result.data!.token);
        } catch (e) {
          print("Advertencia: No se pudo guardar el token en el storage de la web: $e");
        }

        state = state.copyWith(isLoading: false, user: result.data);
        return true; // ¡Ahora sí llega aquí y le avisa a la UI que navegue!
      } else {
        state = state.copyWith(isLoading: false, error: result.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Error interno: $e");
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String dni) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.register(RegisterRequest(name: name, email: email, password: password, dni: dni));

      if (result.success) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: result.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Error interno: $e");
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'jwt_token');
    } catch (e) {
      print("Advertencia al borrar storage: $e");
    }
    state = AuthState();
  }
  Future<void> tryRestoreSession() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token != null && !JwtDecoder.isExpired(token)) {
        final decoded = JwtDecoder.decode(token);
        final expiresAt = JwtDecoder.getExpirationDate(token);

        state = state.copyWith(
          user: LoginResponse(
            token: token,
            name: decoded['nombres'] ?? '',
            email: decoded['email'] ?? '',
            role: '',
            dni: decoded['dni'] ?? '',
            expiresAt: expiresAt,
          ),
        );
      }
    } catch (e) {
      print("No se pudo restaurar sesión: $e");
    }
  }
}


