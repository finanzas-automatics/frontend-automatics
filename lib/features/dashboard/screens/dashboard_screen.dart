import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AutomaticsAppBar(),
      body: dashboardAsync.when(
        data: (data) => _buildBody(context, ref, data),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(error.toString(), style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(dashboardProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.registerClient),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, DashboardResponse data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(ref),
          const SizedBox(height: 24),
          _buildKpiGrid(context, data),
          const SizedBox(height: 32),
          _buildChartsSection(context, data),
          const SizedBox(height: 32),
          _buildRecentActivity(context, data),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final nombre = user?.name ?? 'Asesor Financiero';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $nombre',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Resumen de gestión para hoy',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, DashboardResponse data) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return GridView.count(
      crossAxisCount: isSmall ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isSmall ? 1.15 : 1.55,
      children: [
        KpiCard(
          label: 'Monto Total Financiado',
          value: _formatNumber(data.totalFinanced),
          prefix: 'S/',
          badge: 'Actualizado',
          icon: Icons.payments_outlined,
        ),
        KpiCard(
          label: 'Contratos Activos',
          value: data.activeContracts.toString(),
          badge: 'Actualizado',
          icon: Icons.description_outlined,
        ),
        KpiCard(
          label: 'En Evaluación',
          value: data.inEvaluation.toString(),
          badge: 'Actualizado',
          icon: Icons.pending_actions_outlined,
        ),
        KpiCard(
          label: 'Tasa de Aprobación',
          value: '${data.approvalRate}%',
          badge: 'Actualizado',
          icon: Icons.verified_user_outlined,
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  Widget _buildChartsSection(BuildContext context, DashboardResponse data) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    if (isSmall) {
      return Column(
        children: [
          // Pasamos el context para poder abrir el bottom sheet
          _buildVanChart(context, data.vanHistory, data.vanLabels),
          const SizedBox(height: 16),
          // Pasamos el context para poder abrir el bottom sheet
          _buildTirChart(context, data.tirHistory, data.tirLabels),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildVanChart(context, data.vanHistory, data.vanLabels)),
        const SizedBox(width: 16),
        Expanded(child: _buildTirChart(context, data.tirHistory, data.tirLabels)),
      ],
    );
  }

  // Agregamos BuildContext context a la firma
  Widget _buildVanChart(BuildContext context, List<double> historyData, List<String> labels) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Análisis VAN',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Valor Actual Neto',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Simulaciones',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Activo',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Agregamos el GestureDetector mágico para la línea
          Builder(
            builder: (innerContext) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                if (historyData.isEmpty) return;

                final box = innerContext.findRenderObject() as RenderBox;
                final width = box.size.width;
                final stepX = width / (historyData.length <= 1 ? 1 : historyData.length - 1);

                int indexTocado = (details.localPosition.dx / stepX).round();
                if (indexTocado >= 0 && indexTocado < historyData.length) {
                  _showDetailSheet(
                      context,
                      'Detalle VAN',
                      labels[indexTocado],
                      'S/ ${historyData[indexTocado].toStringAsFixed(2)}'
                  );
                }
              },
              child: SizedBox(
                height: 80,
                child: CustomPaint(
                  painter: _DynamicLinePainter(historyData),
                  size: const Size(double.infinity, 80),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((label) => Text(
              label,
              style: const TextStyle(
                  fontSize: 9,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // Agregamos BuildContext context a la firma
  Widget _buildTirChart(BuildContext context, List<double> rawData, List<String> labels) {
    final maxVal = rawData.isEmpty ? 1.0 : rawData.reduce((a, b) => a > b ? a : b);
    final bars = rawData.map((e) => maxVal == 0 ? 0.1 : (e / maxVal)).toList();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Análisis TIR',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Tasa Interna de Retorno',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                'Mensual',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.asMap().entries.map((e) {
                final isLast = e.key == bars.length - 1;
                final label = labels.length > e.key ? labels[e.key] : '';

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    // Agregamos el GestureDetector para cada barra
                    child: GestureDetector(
                      onTap: () {
                        _showDetailSheet(
                            context,
                            'Detalle TIR',
                            label,
                            '${rawData[e.key].toStringAsFixed(2)} %'
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            height: 80 * e.value,
                            decoration: BoxDecoration(
                              color: isLast ? AppColors.secondary : AppColors.primaryContainer,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            style: const TextStyle(
                                fontSize: 9,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurfaceVariant
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, DashboardResponse data) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Últimas Acciones de Clientes',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.clients),
                  child: const Text(
                    'Ver todo',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryFixed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (data.recentActivity.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No hay actividad reciente',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          for (var i = 0; i < data.recentActivity.length; i++) ...[
            _buildActivityItem(
              initials: _getInitials(data.recentActivity[i].clientName),
              name: data.recentActivity[i].clientName,
              subtitle: data.recentActivity[i].description,
              amount: 'S/ ${data.recentActivity[i].amount.toStringAsFixed(2)}',
              time: data.recentActivity[i].timeAgo,
              onTap: () {
                // ✨ MAGIA CORREGIDA: Si ya está aprobado saca la notificación verde, si no, viaja a la ruta exacta de reportes
                if (data.recentActivity[i].description.toLowerCase().contains("aprobado")) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text('El crédito de ${data.recentActivity[i].clientName} ya se encuentra aprobado.')),
                        ],
                      ),
                      backgroundColor: const Color(0xFF16A34A),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } else {
                  // ✨ AHORA APUNTA EXACTAMENTE A LA PANTALLA DE TU CAPTURA
                  context.go('/simulator/indicators', extra: data.recentActivity[i].id);
                }
              },
            ),
            if (i < data.recentActivity.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildActivityItem({
    required String initials,
    required String name,
    required String subtitle,
    required String amount,
    required String time,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.secondaryFixed,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showDetailSheet(BuildContext context, String titulo, String periodo, String valor) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.insights, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
                      Text('Periodo: $periodo', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Valor Alcanzado', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
            Text(valor, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
                child: const Text('Cerrar Detalle'),
              ),
            )
          ],
        ),
      );
    },
  );
}

class _DynamicLinePainter extends CustomPainter {
  final List<double> data;
  _DynamicLinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (data.length <= 1 ? 1 : data.length - 1);

    double maxVal = data.reduce((a, b) => a > b ? a : b);
    double minVal = data.reduce((a, b) => a < b ? a : b);
    if (maxVal == minVal) { maxVal += 1; minVal -= 1; }
    final range = maxVal - minVal;

    double prevX = 0;
    double prevY = 0;

    for (int i = 0; i < data.length; i++) {
      final normalizedY = (data[i] - minVal) / range;
      final y = size.height - (normalizedY * size.height * 0.6 + size.height * 0.2);
      final x = i * stepX;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final controlX = prevX + (x - prevX) / 2;
        path.cubicTo(controlX, prevY, controlX, y, x, y);
      }
      prevX = x;
      prevY = y;
    }

    canvas.drawPath(path, paint);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.secondary.withValues(alpha: 0.3),
          AppColors.secondary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}