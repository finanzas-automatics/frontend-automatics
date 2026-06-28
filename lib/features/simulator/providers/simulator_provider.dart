import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/simulator_models.dart';
import '../repositories/simulator_repository.dart';

final simulatorRepositoryProvider = Provider<SimulatorRepository>((ref) {
  return SimulatorRepository(ref.watch(dioProvider));
});

final simulationResultProvider = StateProvider<SimulationResponse?>((ref) => null);
final isSimulatingProvider = StateProvider<bool>((ref) => false);
