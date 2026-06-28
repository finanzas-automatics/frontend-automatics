import 'package:dio/dio.dart';
import '../../../core/api/api_response.dart';
import '../models/simulator_models.dart';

class SimulatorRepository {
  final Dio _dio;

  SimulatorRepository(this._dio);

  Future<SimulationResponse> simulate(SimulationRequest request) async {
    try {
      final response = await _dio.post('/Simulator/calculate', data: request.toJson());
      final apiResponse = ApiResponse.fromJson(response.data, (json) => json);
      
      if (!apiResponse.success) {
        throw Exception(apiResponse.message);
      }
      
      return SimulationResponse.fromJson(apiResponse.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error en simulación: $e');
    }
  }
}
