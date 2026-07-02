import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/simulator_models.dart';

final simulatorRepositoryProvider = Provider<SimulatorRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SimulatorRepository(dio);
});

class SimulatorRepository {
  final Dio _dio;
  SimulatorRepository(this._dio);

  Future<SimulationResponse> simulate(SimulationRequest request) async {
    try {
      final response = await _dio.post('/Creditos/simular', data: request.toJson());
      final body = response.data as Map<String, dynamic>;
      final bool exito = body['exito'] as bool? ?? false;
      final String msg  = body['mensaje'] as String? ?? '';
      if (!exito) throw Exception(msg);
      return SimulationResponse.fromJson(body['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error en simulación: $e');
    }
  }

  Future<SimulationResponse> getById(int id) async {
    try {
      final response = await _dio.get('/Creditos/$id');
      final body = response.data as Map<String, dynamic>;
      final bool exito = body['exito'] as bool? ?? false;
      final String msg  = body['mensaje'] as String? ?? '';
      if (!exito) throw Exception(msg);
      return SimulationResponse.fromJson(body['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al obtener el detalle del crédito: $e');
    }
  }

  Future<void> approve(int creditId) async {
    try {
      final response = await _dio.post('/Creditos/$creditId/aprobar');
      final body = response.data as Map<String, dynamic>;
      final bool exito = body['exito'] as bool? ?? false;
      final String msg  = body['mensaje'] as String? ?? '';
      if (!exito) throw Exception(msg);
    } catch (e) {
      throw Exception('Error al aprobar crédito: $e');
    }
  }

  // ✨ NUEVO: Método para borrar simulaciones en evaluación
  Future<void> deleteCredit(int creditId) async {
    try {
      final response = await _dio.delete('/Creditos/$creditId');
      final body = response.data as Map<String, dynamic>;
      final bool exito = body['exito'] as bool? ?? false;
      final String msg  = body['mensaje'] as String? ?? '';
      if (!exito) throw Exception(msg);
    } catch (e) {
      throw Exception('Error al eliminar la simulación: $e');
    }
  }
}