import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clients/providers/client_provider.dart'; // ✨ IMPORTANTE: Para consultar los créditos reales

// ✨ NUEVO PROVEEDOR: Cuenta los créditos realmente colocados en la BD
final totalPlacedCreditsProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(clientRepositoryProvider);
  // Llamamos a la API pidiendo solo 1 registro (para no saturar), filtrando por "aprobado"
  final res = await repo.getClients(page: 1, pageSize: 1, status: 'aprobado');
  return res.totalCount; // Retorna el número exacto (ej. 2)
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Variables de estado para hacer los switches funcionales
  bool _darkMode = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AutomaticsAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            // 1. Tarjeta de Perfil (Con datos reales de tu authState)
            _buildProfileCard(),
            const SizedBox(height: 20),

            // 2. Nuevo Panel: Rendimiento (Conectado a BD real)
            _buildPerformanceCard(),
            const SizedBox(height: 20),

            // 3. Sistema y Legal (Apilados para mejor diseño móvil)
            _buildSystemCard(),
            const SizedBox(height: 20),
            _buildLegalCard(context),
            const SizedBox(height: 32),

            // 4. Botón de Cerrar Sesión
            _buildLogoutButton(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mi Perfil',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primaryContainer),
        ),
        SizedBox(height: 6),
        Text(
          'Gestiona tu cuenta, rendimiento y parámetros del sistema.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  // ✨ TARJETA DE PERFIL (Diseño Premium + Datos Reales)
  Widget _buildProfileCard() {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    final name = user?.name ?? 'Asesor Financiero';
    final email = user?.email ?? 'Cargando...';
    final id = user?.dni ?? '---';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, Color(0xFF1A3A6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary, width: 3),
            ),
            child: const Center(
              child: Icon(Icons.person, size: 40, color: AppColors.primaryContainer),
            ),
          ),
          const SizedBox(height: 16),
          Text(name,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(email,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.secondaryContainer),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(99)),
            child: Text('ID (DNI): $id',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ✨ TARJETA: Rendimiento (Dinámica, ya no muestra el '14' quemado)
  Widget _buildPerformanceCard() {
    return Consumer(
        builder: (context, ref, child) {
          final totalAsync = ref.watch(totalPlacedCreditsProvider);

          // Si está cargando o falla, mostramos 0 por defecto.
          final totalPlaced = totalAsync.value ?? 0;
          const target = 20; // Meta mensual

          return SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: AppColors.secondary, size: 22),
                    SizedBox(width: 8),
                    Text('Mi Rendimiento (Este Mes)',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        icon: Icons.directions_car_filled_outlined,
                        value: totalPlaced.toString(), // ✨ Total real de la BD
                        label: 'Créditos\nColocados',
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.outlineVariant),
                    Expanded(
                      child: _buildMetricItem(
                        icon: Icons.pie_chart_outline_rounded,
                        value: '${((totalPlaced / target) * 100).toInt()}%', // ✨ Tasa calculada
                        label: 'Tasa de\nConversión',
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Meta Mensual: $target Vehículos',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (totalPlaced / target).clamp(0.0, 1.0), // ✨ Progreso real
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  Widget _buildMetricItem({required IconData icon, required String value, required String label, required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.2)),
      ],
    );
  }

  // ✨ SISTEMA FUNCIONAL (Modo oscuro y Notificaciones)
  Widget _buildSystemCard() {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Icon(Icons.settings_outlined, color: AppColors.primaryContainer, size: 20),
                SizedBox(width: 8),
                Text('Sistema', style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryContainer)),
              ],
            ),
          ),
          _buildSwitchTile(
            title: 'Modo Oscuro',
            subtitle: 'Ajustar la apariencia visual',
            icon: Icons.dark_mode_outlined,
            value: _darkMode,
            onChanged: (val) {
              setState(() => _darkMode = val);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(val ? 'Modo Oscuro activado (Simulado)' : 'Modo Claro activado'),
                duration: const Duration(seconds: 1),
              ));
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildSwitchTile(
            title: 'Notificaciones',
            subtitle: 'Alertas de nuevos créditos y pagos',
            icon: Icons.notifications_none_rounded,
            value: _notifications,
            onChanged: (val) {
              setState(() => _notifications = val);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required IconData icon, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.secondary,
      activeTrackColor: AppColors.secondaryContainer.withValues(alpha: 0.3),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
      subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant)),
    );
  }

  // ✨ SECCIÓN LEGAL CON POPUPS
  Widget _buildLegalCard(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Icon(Icons.gavel_rounded, color: AppColors.primaryContainer, size: 20),
                SizedBox(width: 8),
                Text('Legal', style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryContainer)),
              ],
            ),
          ),
          _buildLegalTile(
            context,
            title: 'Regulaciones SBS',
            icon: Icons.account_balance_outlined,
            contentTitle: 'Cumplimiento Normativo SBS',
            contentText: 'Esta plataforma opera bajo los lineamientos de la Resolución SBS N.º 8181-2012 (Reglamento de Transparencia). Todos los cálculos de TCEA, VAN y TIR cumplen estrictamente con las normativas vigentes en el Perú.',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildLegalTile(
            context,
            title: 'Políticas de Privacidad',
            icon: Icons.shield_outlined,
            contentTitle: 'Protección de Datos Personales',
            contentText: 'En AutoMatics garantizamos la confidencialidad de la información crediticia y personal, en cumplimiento con la Ley N° 29733 de Protección de Datos Personales.',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildLegalTile(
            context,
            title: 'Términos de Uso',
            icon: Icons.description_outlined,
            contentTitle: 'Términos para Asesores',
            contentText: 'El uso de esta plataforma está restringido exclusivamente a asesores autorizados. Te comprometes a brindar información veraz y a no manipular tasas fuera de los rangos de la entidad.',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLegalTile(BuildContext context, {required String title, required IconData icon, required String contentTitle, required String contentText}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.onSurfaceVariant),
      onTap: () => _showLegalBottomSheet(context, contentTitle, contentText, icon),
    );
  }

  void _showLegalBottomSheet(BuildContext context, String title, String content, IconData icon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: AppColors.secondaryContainer.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(icon, size: 30, color: AppColors.secondary),
              ),
              const SizedBox(height: 20),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primaryContainer)),
              const SizedBox(height: 16),
              Text(content, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text('Cerrar Sesión', style: TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cerrar Sesión', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: AppColors.primary)),
        content: const Text('¿Estás seguro de que deseas salir del sistema?', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: AppColors.onSurfaceVariant))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authStateProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}