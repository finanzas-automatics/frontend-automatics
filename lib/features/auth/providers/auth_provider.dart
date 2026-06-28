import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/api/api_client.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(secureStorageProvider),
  );
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
      error: error, // Can be set to null if not provided or deliberately clear
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
    
    final result = await _repository.login(LoginRequest(email: email, password: password));
    
    if (result.success && result.data != null) {
      await _storage.write(key: 'jwt_token', value: result.data!.token);
      state = state.copyWith(isLoading: false, user: result.data);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result.message);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String dni) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _repository.register(RegisterRequest(name: name, email: email, password: password, dni: dni));
    
    if (result.success) {
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result.message);
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    state = AuthState(); // Reset state
  }
}
