import 'package:dio/dio.dart';
import '../../../core/api/api_response.dart';
import '../models/client_models.dart';

class ClientRepository {
  final Dio _dio;

  ClientRepository(this._dio);

  Future<PagedResponse<ClientListResponse>> getClients({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'pageSize': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final response = await _dio.get('/Clients', queryParameters: queryParams);
      final apiResponse = ApiResponse.fromJson(response.data, (json) => json as Map<String, dynamic>);
      if (!apiResponse.success) throw Exception(apiResponse.message);

      return PagedResponse<ClientListResponse>.fromJson(
        apiResponse.data as Map<String, dynamic>,
        (json) => ClientListResponse.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Error al obtener clientes: $e');
    }
  }

  Future<ClientResponse> getClientById(int id) async {
    try {
      final response = await _dio.get('/Clients/$id');
      final apiResponse = ApiResponse.fromJson(response.data, (json) => json);
      if (!apiResponse.success) throw Exception(apiResponse.message);
      return ClientResponse.fromJson(apiResponse.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al obtener cliente: $e');
    }
  }

  Future<ClientResponse> createClient(ClientCreateRequest request) async {
    try {
      final response = await _dio.post('/Clients', data: request.toJson());
      final apiResponse = ApiResponse.fromJson(response.data, (json) => json);
      if (!apiResponse.success) throw Exception(apiResponse.message);
      return ClientResponse.fromJson(apiResponse.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al crear cliente: $e');
    }
  }

  Future<ClientResponse> updateClient(int id, ClientUpdateRequest request) async {
    try {
      final response = await _dio.put('/Clients/$id', data: request.toJson());
      final apiResponse = ApiResponse.fromJson(response.data, (json) => json);
      if (!apiResponse.success) throw Exception(apiResponse.message);
      return ClientResponse.fromJson(apiResponse.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al actualizar cliente: $e');
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      final response = await _dio.delete('/Clients/$id');
      final apiResponse = ApiResponse.fromJson(response.data, (json) => json);
      if (!apiResponse.success) throw Exception(apiResponse.message);
    } catch (e) {
      throw Exception('Error al eliminar cliente: $e');
    }
  }
}
