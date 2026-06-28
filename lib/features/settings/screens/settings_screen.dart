import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _defaultCurrency = 'S/';
  String _defaultRateType = 'TEA';
  String _capitalization = 'Mensual';
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
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildPreferencesCard(),
            const SizedBox(height: 16),
            _buildSystemAndLegalRow(),
            const SizedBox(height: 16),
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
        Text('Configuración',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
        Text('Gestiona tus preferencias de asesor y parámetros del sistema.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    final name = user?.name ?? 'Cargando...';
    final role = user?.role ?? 'Asesor';
    final dni = user?.dni ?? 'Sin ID';

    return SectionCard(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondaryContainer.withValues(alpha: 0.2), width: 3),
                    ),
                    child: ClipOval(
                      child: Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Icon(Icons.person, size: 50, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(name,
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  Text(role,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(99)),
                    child: Text('ID: $dni',
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_outlined, color: AppColors.secondary, size: 20),
              SizedBox(width: 8),
              Text('Preferencias de Simulación',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildPreferenceRow(
            'Moneda Predeterminada',
            'Define si las cotizaciones inician en Soles o Dólares.',
            Row(
              children: ['S/', 'USD \$'].map((c) {
                final sel = _defaultCurrency == c;
                return GestureDetector(
                  onTap: () => setState(() => _defaultCurrency = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.surfaceContainerLowest : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: sel ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)] : null,
                    ),
                    child: Text(c, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: sel ? AppColors.secondary : AppColors.onSurfaceVariant)),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 20),
          _buildPreferenceRow(
            'Tipo de Tasa Preferida',
            'Selección automática entre TEA y TNA.',
            Row(
              children: ['TEA', 'TNA'].map((t) {
                final sel = _defaultRateType == t;
                return GestureDetector(
                  onTap: () => setState(() => _defaultRateType = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.surfaceContainerLowest : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: sel ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)] : null,
                    ),
                    child: Text(t, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: sel ? AppColors.secondary : AppColors.onSurfaceVariant)),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 20),
          _buildPreferenceRow(
            'Capitalización Predeterminada',
            'Frecuencia de capitalización para cálculos de tasa.',
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _capitalization,
                  items: ['Diaria', 'Mensual', 'Anual'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontFamily: 'Inter', fontSize: 13)))).toList(),
                  onChanged: (v) => setState(() => _capitalization = v!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(String title, String subtitle, Widget control) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(2),
          child: control,
        ),
      ],
    );
  }

  Widget _buildSystemAndLegalRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildSystemCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildLegalCard()),
      ],
    );
  }

  Widget _buildSystemCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.settings_suggest_outlined, color: AppColors.secondary, size: 18),
              SizedBox(width: 6),
              Text('Sistema', style: TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 14),
          _switchRow('Modo Oscuro', _darkMode, (v) => setState(() => _darkMode = v)),
          const Divider(height: 16),
          _switchRow('Notificaciones', _notifications, (v) => setState(() => _notifications = v)),
        ],
      ),
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurface)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildLegalCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gavel_outlined, color: AppColors.secondary, size: 18),
              SizedBox(width: 6),
              Text('Legal', style: TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 14),
          _legalLink('Regulaciones SBS'),
          const Divider(height: 14),
          _legalLink('Privacidad'),
          const Divider(height: 14),
          _legalLink('Términos de Uso'),
        ],
      ),
    );
  }

  Widget _legalLink(String label) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurface)),
          const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant, size: 18),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_outlined, size: 18),
        label: const Text('Cerrar Sesión'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.onError,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: AppColors.primary)),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); context.go(AppRoutes.login); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
