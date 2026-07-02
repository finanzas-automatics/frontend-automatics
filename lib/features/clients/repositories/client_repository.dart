import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/client_models.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ClientRepository(dio);
});

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
      final body = response.data as Map<String, dynamic>;

      // ✅ Leer wrapper en español
      final bool exito = body['exito'] as bool? ?? false;
      final String msg  = body['mensaje'] as String? ?? '';
      if (!exito) throw Exception(msg);

      final data = body['data'] as Map<String, dynamic>;
      return PagedResponse<ClientListResponse>.fromJson(
        data,
            (json) => ClientListResponse.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Error al obtener clientes: $e');
    }
  }

  Future<ClientResponse> getClientById(int id) async {
    try {
      final response = await _dio.get('/Clients/$id');
      final body = response.data as Map<String, dynamic>;

      final bool exito = body['exito'] as bool? ?? false;
      final String msg  = body['mensaje'] as String? ?? '';
      if (!exito) throw Exception(msg);

      return ClientResponse.fromJson(body['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al obtener cliente: $e');
    }
  }

  Future<ClientResponse> createClient(ClientCreateRequest request) async {
    try {
      final response = await _dio.post('/Clients', data: request.toJson());
      final body = response.data as Map<String, dynamic>;

      final bool exito = body['exito'] as bool? ?? false;
      final String msg  = body['mensaje'] as String? ?? '';
      if (!exito) throw Exception(msg);

      // ✅ El backend devuelve solo el ID (data: 1), no el objeto completo
      // Hacemos una segunda llamada para obtener el cliente recién creado
      final dynamic rawData = body['data'];
      if (rawData is int) {
        return await getClientById(rawData);
      } else if (rawData is Map<String, dynamic>) {
        // Por si en el futuro el backend devuelve el objeto completo
        return ClientResponse.fromJson(rawData);
      } else {
        throw Exception('Respuesta inesperada del servidor al crear cliente');
      }
    } catch (e) {
      throw Exception('Error al crear cliente: $e');
    }
  }

  Future<ClientResponse> updateClient(int id, ClientUpdateRequest request) async {
    try {
      final response = await _dio.put('/Clients/$id', data: request.toJson());
      final body = response.data as Map<String, dynamic>;

      final bool exito = body['exito'] as bool? ?? false;
      final String msg  = body['mensaje'] as String? ?? '';
      if (!exito) throw Exception(msg);

      final dynamic rawData = body['data'];
      if (rawData is int) {
        return await getClientById(rawData);
      } else if (rawData is Map<String, dynamic>) {
        return ClientResponse.fromJson(rawData);
      } else {
        throw Exception('Respuesta inesperada del servidor al actualizar cliente');
      }
    } catch (e) {
      throw Exception('Error al actualizar cliente: $e');
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      final response = await _dio.delete('/Clients/$id');
      final body = response.data as Map<String, dynamic>;

      final bool exito = body['exito'] as bool? ?? false;
      final String msg  = body['mensaje'] as String? ?? '';
      if (!exito) throw Exception(msg);
    } catch (e) {
      throw Exception('Error al eliminar cliente: $e');
    }
  }
}