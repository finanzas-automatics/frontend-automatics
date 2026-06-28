import 'package:dio/dio.dart';
import '../../../core/api/api_response.dart';
import '../models/dashboard_models.dart';

class DashboardRepository {
  final Dio _dio;

  DashboardRepository(this._dio);

  Future<DashboardResponse> getDashboard() async {
    try {
      final response = await _dio.get('/Dashboard');
      final apiResponse = ApiResponse.fromJson(response.data, (json) => json);
      if (!apiResponse.success) {
        throw Exception(apiResponse.message);
      }
      return DashboardResponse.fromJson(apiResponse.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al obtener dashboard: $e');
    }
  }
}
