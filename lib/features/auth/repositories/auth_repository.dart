import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/Auth/login', data: {
        'email': request.email,
        'password': request.password,
      });

      final responseData = response.data as Map<String, dynamic>;
      final bool exito   = responseData['exito']  as bool?   ?? false;
      final String msg   = responseData['mensaje'] as String? ?? '';
      final String? token = responseData['data']  as String?;

      if (exito && token != null && token.isNotEmpty) {
        // ✅ ¡AQUÍ ESTÁ LA MAGIA! En el REPOSITORIO
        final loginData = LoginResponse.fromJson(responseData);

        return ApiResponse<LoginResponse>(
          success: true,
          message: msg,
          data: loginData,
        );
      }

      return ApiResponse<LoginResponse>(success: false, message: msg);

    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final err = e.response!.data as Map<String, dynamic>;
        return ApiResponse<LoginResponse>(
          success: false,
          message: err['mensaje'] ?? 'Credenciales inválidas',
        );
      }
      return ApiResponse<LoginResponse>(success: false, message: e.message ?? 'Error de red');
    } catch (e) {
      return ApiResponse<LoginResponse>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<String>> register(RegisterRequest request) async {
    try {
      final parts = request.name.trim().split(' ');
      final nombres = parts.isNotEmpty ? parts[0] : '';
      final apellidos = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      // ¡AQUÍ ESTÁ EL CAMBIO! Ahora dice /Auth/register
      final response = await _dio.post('/Auth/register', data: {
        'nombres': nombres,
        'apellidos': apellidos,
        'correo': request.email,
        'password': request.password,
        'dni': request.dni
      });

      final apiResponse = ApiResponse<bool>.fromJson(
        response.data,
            (json) => json as bool,
      );

      return ApiResponse<String>(
          success: apiResponse.success,
          message: apiResponse.message,
          data: apiResponse.success ? "Registrado" : null
      );

    } on DioException catch (e) {
      // Control de seguridad: Si el backend no responde con un JSON válido (como en un 404)
      if (e.response != null && e.response?.data != null && e.response?.data is Map) {
        final errorData = e.response!.data as Map<String, dynamic>;
        return ApiResponse<String>(success: false, message: errorData['mensaje'] ?? 'Error al registrar');
      }
      return ApiResponse<String>(success: false, message: e.message ?? 'Unknown error');
    } catch (e) {
      return ApiResponse<String>(success: false, message: e.toString());
    }
  }
}