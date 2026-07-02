import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/dashboard_models.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardRepository(dio);
});

class DashboardRepository {
  final Dio _dio;

  DashboardRepository(this._dio);

  Future<DashboardResponse> getDashboard() async {
    try {
      final response = await _dio.get('/Dashboard/resumen');
      final body = response.data as Map<String, dynamic>;

      // ✅ El backend envuelve la respuesta en {exito, mensaje, data: {...}}
      // Intentamos leer 'data', si no existe asumimos que el body ES la data
      final Map<String, dynamic> data;
      if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
        data = body['data'] as Map<String, dynamic>;
      } else if (body.containsKey('exito')) {
        // Wrapper sin 'data' o 'data' es null — usamos defaults
        data = {};
      } else {
        data = body;
      }

      return DashboardResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception('Error al obtener dashboard: ${e.message}');
    } catch (e) {
      throw Exception('Error al obtener dashboard: $e');
    }
  }
}