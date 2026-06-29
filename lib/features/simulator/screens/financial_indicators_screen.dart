import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../providers/simulator_provider.dart';
import '../models/simulator_models.dart';

class FinancialIndicatorsScreen extends ConsumerWidget {
  const FinancialIndicatorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(simulationResultProvider);

    if (result == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AutomaticsAppBar(showBack: true, onBack: () => context.pop()),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_outlined,
                  size: 56, color: AppColors.outlineVariant),
              const SizedBox(height: 16),
              const Text(
                'Sin simulación activa',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ejecuta una simulación primero.',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AutomaticsAppBar(showBack: true, onBack: () => context.pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildIndicatorCards(result),
            const SizedBox(height: 20),
            _buildBalanceChart(result),
            const SizedBox(height: 20),
            _buildStatusBanner(result),
            const SizedBox(height: 16),
            _buildApproveButton(),
          ],
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Indicadores\nFinancieros',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryContainer,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Visualización técnica de la rentabilidad y costos '
              'financieros proyectados para su crédito vehicular.',
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.1),
            border: Border.all(
                color: AppColors.secondaryContainer.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline,
                  size: 14, color: AppColors.secondary),
              SizedBox(width: 6),
              Text(
                'Cálculos desde la perspectiva del deudor.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── INDICATOR CARDS ───────────────────────────────────────────────────────

  Widget _buildIndicatorCards(SimulationResponse result) {
    return Column(
      children: [
        _buildVanCard(result.van),
        const SizedBox(height: 12),
        _buildTirCard(result.tirMonthly),
        const SizedBox(height: 12),
        _buildTceaCard(result.tcea),
      ],
    );
  }

  Widget _buildVanCard(double van) {
    final isNeg = van < 0;
    return SectionCard(
      borderLeftColor: isNeg ? AppColors.error : AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'VALOR ACTUAL NETO (VAN)',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isNeg
                      ? AppColors.errorContainer.withValues(alpha: 0.3)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Icon(
                  isNeg
                      ? Icons.trending_down_rounded
                      : Icons.trending_up_rounded,
                  size: 16,
                  color: isNeg ? AppColors.error : const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'S/ ${van.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: isNeg ? AppColors.error : AppColors.secondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isNeg
                  ? AppColors.errorContainer.withValues(alpha: 0.25)
                  : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isNeg
                  ? 'Un VAN negativo desde la perspectiva del deudor representa el costo financiero neto actualizado del préstamo.'
                  : 'El VAN positivo indica que el financiamiento es favorable para el deudor bajo la tasa de descuento indicada.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: isNeg
                    ? AppColors.onErrorContainer
                    : const Color(0xFF166534),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTirCard(double tir) {
    return SectionCard(
      borderLeftColor: AppColors.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TASA INTERNA DE RETORNO (TIR)',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Icon(Icons.account_balance_outlined,
                  color: AppColors.secondaryContainer, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: tir.toStringAsFixed(2),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryContainer,
                ),
              ),
              const TextSpan(
                text: ' %',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Nota de equivalencia: Representa el costo efectivo mensual capitalizado anualmente de los flujos del préstamo.',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTceaCard(double tcea) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TCEA PROYECTADA',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              // SBS badge
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_outlined,
                        size: 12, color: Color(0xFF16A34A)),
                    SizedBox(width: 4),
                    Text(
                      'SBS',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: tcea.toStringAsFixed(4),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryContainer,
                ),
              ),
              const TextSpan(
                text: ' %',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Calculado bajo SBS Resolución Nº 8181-2012. Incluye tasa de interés, comisiones y gastos del seguro.',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  // ── CHART ────────────────────────────────────────────────────────────────

  Widget _buildBalanceChart(SimulationResponse result) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evolución del Saldo Deudor',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryContainer,
            ),
          ),
          Text(
            'Proyección del capital pendiente a lo largo de '
                '${result.schedule.length} meses.',
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              const Text('Saldo Capital',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _BalanceChartPainter(schedule: result.schedule),
              size: const Size(double.infinity, 160),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mes 0',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant)),
              Text(
                'Mes ${result.schedule.length ~/ 2}',
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant),
              ),
              Text(
                'Mes ${result.schedule.length}',
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STATUS BANNER ────────────────────────────────────────────────────────

  Widget _buildStatusBanner(SimulationResponse result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryContainer, Color(0xFF1A3A6E)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTADO DEL SIMULADOR',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Crédito en Evaluación Óptima',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Su perfil califica para tasas preferenciales basadas '
                'en el análisis de flujo de caja realizado.',
            style: TextStyle(
                fontFamily: 'Inter', fontSize: 12, color: AppColors.onPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text('Descargar Reporte SBS',
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryContainer,
                    foregroundColor: AppColors.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Cuota Mensual',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'S/ ${result.monthlyPayment.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryContainer,
                        ),
                      ),
                      const Text(
                        'Incluye seguros de ley',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          color: AppColors.onPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApproveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.check_circle_outline, size: 18),
        label: const Text('Aprobar Crédito'),
      ),
    );
  }
}

// ── CHART PAINTER ─────────────────────────────────────────────────────────────

class _BalanceChartPainter extends CustomPainter {
  final List<ScheduleRowResponse> schedule;
  const _BalanceChartPainter({required this.schedule});

  @override
  void paint(Canvas canvas, Size size) {
    if (schedule.isEmpty) return;

    final maxBalance = schedule.first.initialBalance;
    if (maxBalance <= 0) return;

    // Build data points (include month-0 = full balance)
    final points = <Offset>[];
    points.add(Offset(0, 0)); // top-left = max balance
    for (int i = 0; i < schedule.length; i++) {
      final x = size.width * (i + 1) / schedule.length;
      final normalised = schedule[i].finalBalance / maxBalance;
      final y = size.height * (1 - normalised.clamp(0, 1));
      points.add(Offset(x, y));
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    for (int i = 1; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Fill path
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 =
      Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      fillPath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.secondaryContainer.withValues(alpha: 0.35),
            AppColors.secondaryContainer.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    // Line path
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 =
      Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      linePath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.secondaryContainer
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Dots at start, mid, end
    final dotPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = AppColors.surfaceContainerLowest
      ..style = PaintingStyle.fill;

    for (final p in [
      points.first,
      points[points.length ~/ 2],
      points.last
    ]) {
      canvas.drawCircle(p, 5, dotBorder);
      canvas.drawCircle(p, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BalanceChartPainter old) =>
      old.schedule != schedule;
}