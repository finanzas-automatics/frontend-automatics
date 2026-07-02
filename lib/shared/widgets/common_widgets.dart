import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✨ IMPORTANTE para la navegación
import '../../core/theme/app_theme.dart';

class AutomaticsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  const AutomaticsAppBar({
    super.key,
    this.title,
    this.actions,
    this.showBack = false,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      shadowColor: const Color(0xFF0A1F44).withValues(alpha: 0.05),
      // ✨ LADO IZQUIERDO: Flecha de retroceso o Nuevo Menú de Herramientas
      leading: showBack
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
        onPressed: onBack ?? () => context.pop(),
      )
          : PopupMenuButton<String>(
        icon: const Icon(Icons.apps_rounded, color: AppColors.onPrimary),
        tooltip: 'Más opciones',
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        offset: const Offset(0, 45), // Desplaza el menú hacia abajo
        onSelected: (value) {
          if (value == 'notificaciones') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No tienes notificaciones pendientes.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (value == 'soporte') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Abriendo centro de soporte técnico...'),
                backgroundColor: AppColors.secondary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'notificaciones',
            child: Row(
              children: [
                Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Text('Notificaciones', style: TextStyle(fontFamily: 'Inter', color: AppColors.primary, fontSize: 14)),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'soporte',
            child: Row(
              children: [
                Icon(Icons.headset_mic_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Text('Soporte Técnico', style: TextStyle(fontFamily: 'Inter', color: AppColors.primary, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      title: Text(
        title ?? 'AutoMatics',
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
      ),
      // ✨ LADO DERECHO: Acciones personalizadas o el botón de Perfil por defecto
      actions: actions ??
          [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.account_circle_outlined, color: AppColors.onPrimary, size: 26),
                tooltip: 'Mi Perfil',
                // ✨ REDIRECCIÓN: Te lleva a la pantalla de settings
                onPressed: () => context.go('/settings'),
              ),
            ),
          ],
    );
  }
}

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String prefix;
  final String badge;
  final IconData icon;
  final Color borderColor;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.prefix = '',
    required this.badge,
    required this.icon,
    this.borderColor = AppColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1F44).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(icon, color: AppColors.secondary, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                if (prefix.isNotEmpty)
                  TextSpan(
                    text: '$prefix ',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up, size: 12, color: Color(0xFF16A34A)),
                const SizedBox(width: 2),
                Text(
                  badge,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderLeftColor;

  const SectionCard({
    super.key,
    required this.child,
    this.padding,
    this.borderLeftColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: borderLeftColor != null
            ? Border(left: BorderSide(color: borderLeftColor!, width: 4))
            : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1F44).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color dotColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.dotColor,
  });

  factory StatusBadge.active() => const StatusBadge(
    label: 'Activo',
    backgroundColor: Color(0xFFDCFCE7),
    textColor: Color(0xFF166534),
    dotColor: Color(0xFF22C55E),
  );

  factory StatusBadge.evaluation() => const StatusBadge(
    label: 'En Evaluación',
    backgroundColor: Color(0xFFFEF9C3),
    textColor: Color(0xFF854D0E),
    dotColor: Color(0xFFEAB308),
  );

  factory StatusBadge.pending() => const StatusBadge(
    label: 'Pendiente',
    backgroundColor: Color(0xFFDBEAFE),
    textColor: Color(0xFF1E40AF),
    dotColor: Color(0xFF3B82F6),
  );

  factory StatusBadge.overdue() => const StatusBadge(
    label: 'En Mora',
    backgroundColor: Color(0xFFFEE2E2),
    textColor: Color(0xFF991B1B),
    dotColor: Color(0xFFEF4444),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}