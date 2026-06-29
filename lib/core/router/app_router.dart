import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/clients/screens/clients_list_screen.dart';
import '../../features/clients/screens/register_client_screen.dart';
import '../../features/clients/screens/edit_client_screen.dart';
import '../../features/clients/screens/client_profile_screen.dart';
import '../../features/simulator/screens/simulator_screen.dart';
import '../../features/simulator/screens/payment_schedule_screen.dart';
import '../../features/simulator/screens/financial_indicators_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/';
  static const clients = '/clients';
  static const registerClient = '/clients/register';
  static const editClient = '/clients/:id/edit';
  static const clientProfile = '/clients/:id';
  static const simulator = '/simulator';
  static const paymentSchedule = '/simulator/schedule';
  static const financialIndicators = '/simulator/indicators';
  static const settings = '/settings';
}

final GoRouter appRouter = GoRouter(
  //initialLocation: AppRoutes.login,
  initialLocation: AppRoutes.dashboard,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.clients,
          builder: (context, state) => const ClientsListScreen(),
        ),
        GoRoute(
          path: AppRoutes.registerClient,
          builder: (context, state) => const RegisterClientScreen(),
        ),
        GoRoute(
          path: AppRoutes.editClient,
          builder: (context, state) {
            final clientId = state.pathParameters['id'] ?? '';
            return EditClientScreen(clientId: clientId);
          },
        ),
        GoRoute(
          path: AppRoutes.clientProfile,
          builder: (context, state) {
            final clientId = state.pathParameters['id'] ?? '';
            return ClientProfileScreen(clientId: clientId);
          },
        ),
        GoRoute(
          path: AppRoutes.simulator,
          builder: (context, state) => const SimulatorScreen(),
        ),
        GoRoute(
          path: AppRoutes.paymentSchedule,
          builder: (context, state) => const PaymentScheduleScreen(),
        ),
        GoRoute(
          path: AppRoutes.financialIndicators,
          builder: (context, state) => const FinancialIndicatorsScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
