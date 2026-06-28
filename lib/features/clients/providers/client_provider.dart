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
