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
      final response = await _dio.post('/Auth/login', data: request.toJson());
      return ApiResponse.fromJson(
        response.data,
        (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(
          e.response!.data,
          (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
        );
      }
      return ApiResponse(success: false, message: e.message ?? 'Unknown error');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<String>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post('/Auth/register', data: request.toJson());
      return ApiResponse.fromJson(
        response.data,
        (json) => json as String,
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(
          e.response!.data,
          (json) => json as String,
        );
      }
      return ApiResponse(success: false, message: e.message ?? 'Unknown error');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
