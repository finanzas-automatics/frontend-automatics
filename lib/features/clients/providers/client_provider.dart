import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/client_models.dart';
import '../repositories/client_repository.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(ref.watch(dioProvider));
});

final clientsFilterProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'page': 1,
    'pageSize': 20,
    'search': null,
    'status': null,
  };
});

final clientsListProvider = FutureProvider.autoDispose<PagedResponse<ClientListResponse>>((ref) async {
  final repository = ref.watch(clientRepositoryProvider);
  final filters = ref.watch(clientsFilterProvider);

  return repository.getClients(
    page: filters['page'] as int,
    pageSize: filters['pageSize'] as int,
    search: filters['search'] as String?,
    status: filters['status'] as String?,
  );
});

final clientDetailProvider = FutureProvider.autoDispose.family<ClientResponse, int>((ref, id) async {
  final repository = ref.watch(clientRepositoryProvider);
  return repository.getClientById(id);
});

// ✨ NUEVO: El proveedor que descarga todos los créditos de un solo cliente
final clientHistoryProvider = FutureProvider.autoDispose.family<List<dynamic>, int>((ref, id) async {
  final dio = ref.watch(dioProvider);
  try {
    // LLamamos a la ruta exacta de tu CreditosController.cs
    final response = await dio.get('/Creditos/cliente/$id');
    final data = response.data as Map<String, dynamic>;
    final bool exito = data['exito'] as bool? ?? false;

    if (!exito) throw Exception(data['mensaje'] ?? 'Error desconocido');
    return data['data'] as List<dynamic>;
  } catch (e) {
    throw Exception('No se pudo obtener el historial de créditos: $e');
  }
});