import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/dashboard_models.dart';
import '../repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(dioProvider));
});

final dashboardProvider = FutureProvider.autoDispose<DashboardResponse>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getDashboard();
});
