import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/simulator_models.dart';
import '../repositories/simulator_repository.dart';

final simulationResultProvider = StateProvider<SimulationResponse?>((ref) => null);
final isSimulatingProvider = StateProvider<bool>((ref) => false);
