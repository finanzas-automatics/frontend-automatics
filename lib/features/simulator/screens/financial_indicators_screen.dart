import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../providers/simulator_provider.dart';

class FinancialIndicatorsScreen extends ConsumerWidget {
  const FinancialIndicatorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(simulationResultProvider);

    if (result == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AutomaticsAppBar(
          showBack: true,
          onBack: () => context.pop(),
        ),
        body: const Center(
          child: Text('No hay simulación activa.', style: TextStyle(color: AppColors.onSurfaceVariant)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AutomaticsAppBar(
        showBack: true,
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildMetricsGrid(result.van, result.tirMonthly, result.tcea),
            const SizedBox(height: 20),
            _buildChart(),
            const SizedBox(height: 20),
            _buildActionBanner(result.monthlyPayment),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Indicadores Financieros',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primaryContainer),
        ),
        const SizedBox(height: 4),
        const Text('Visualización técnica de la rentabilidad y costos financieros proyectados para su crédito vehicular.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.secondaryContainer.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info, size: 14, color: AppColors.secondary),
              SizedBox(width: 6),
              Text('Cálculos desde la perspectiva del deudor.',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSecondaryContainer),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(double van, double tir, double tcea) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildVanCard(van)),
            const SizedBox(width: 12),
            Expanded(child: _buildTirCard(tir)),
          ],
        ),
        const SizedBox(height: 12),
        _buildTceaCard(tcea),
      ],
    );
  }

  Widget _buildVanCard(double van) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('VAN', style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onSurfaceVariant)),
              ),
              Icon(Icons.trending_down, color: AppColors.error, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text('S/ ${van.toStringAsFixed(2)}',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryContainer),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'VAN negativo = costo neto actualizado del crédito para el cliente.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTirCard(double tir) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('TIR', style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onSurfaceVariant))),
              Icon(Icons.account_balance_outlined, color: AppColors.secondaryContainer, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(children: [
              TextSpan(text: tir.toStringAsFixed(2), style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryContainer)),
              const TextSpan(text: '%', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.secondaryContainer)),
            ]),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Costo efectivo mensual capitalizado anualmente.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTceaCard(double tcea) {
    return SectionCard(
      child: Row(
        children: [
          const Icon(Icons.gavel, color: AppColors.tertiaryContainer, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TCEA PROYECTADA', style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text('${tcea.toStringAsFixed(2)}%',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primaryContainer),
                ),
                const Text('Calculado bajo SBS Resolución N° 8181-2012.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4EA),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text('SBS', style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1E7E34))),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Evolución del Saldo Deudor',
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryContainer),
          ),
          const Text('Proyección del capital pendiente a lo largo del tiempo.',
            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('Saldo Capital', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _BalanceCurvePainter(),
              size: const Size(double.infinity, 140),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Inicio', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.onSurfaceVariant)),
              Text('Fin', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBanner(double monthly) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ESTADO DEL SIMULADOR',
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onPrimary),
          ),
          const SizedBox(height: 6),
          const Text('Crédito en Evaluación Óptima',
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onPrimary),
          ),
          const SizedBox(height: 6),
          const Text('Su perfil califica para tasas preferenciales basadas en el análisis de flujo de caja.',
            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryContainer,
                    foregroundColor: AppColors.onSecondaryContainer,
                  ),
                  child: const Text('Descargar Reporte SBS', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surfaceContainerLow.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    const Text('Cuota Mensual', style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
                    Text('S/ ${monthly.toStringAsFixed(2)}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.secondaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double y = 0; y <= size.height; y += size.height / 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.secondaryContainer.withValues(alpha: 0.3), AppColors.secondaryContainer.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.secondaryContainer
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dataPoints = [
      Offset(0, size.height * 0.05),
      Offset(size.width * 0.12, size.height * 0.15),
      Offset(size.width * 0.25, size.height * 0.28),
      Offset(size.width * 0.4, size.height * 0.43),
      Offset(size.width * 0.55, size.height * 0.58),
      Offset(size.width * 0.7, size.height * 0.72),
      Offset(size.width * 0.85, size.height * 0.86),
      Offset(size.width, size.height * 0.98),
    ];

    final linePath = Path();
    linePath.moveTo(dataPoints[0].dx, dataPoints[0].dy);
    for (int i = 1; i < dataPoints.length; i++) {
      final cp1 = Offset((dataPoints[i - 1].dx + dataPoints[i].dx) / 2, dataPoints[i - 1].dy);
      final cp2 = Offset((dataPoints[i - 1].dx + dataPoints[i].dx) / 2, dataPoints[i].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, dataPoints[i].dx, dataPoints[i].dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()
      ..color = AppColors.onSecondaryContainer
      ..style = PaintingStyle.fill;
    for (final p in [dataPoints.first, dataPoints[dataPoints.length ~/ 2], dataPoints.last]) {
      canvas.drawCircle(p, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
