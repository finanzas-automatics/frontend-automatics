import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../providers/simulator_provider.dart';
import '../models/simulator_models.dart';

class PaymentScheduleScreen extends ConsumerWidget {
  const PaymentScheduleScreen({super.key});

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

    final schedule = result.schedule;
    final totalInterest = result.totalInterest;
    final totalPaid = result.totalPayment;
    final tcea = result.tcea;

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
            _buildLoanSummaryCard(result),
            const SizedBox(height: 20),
            _buildTable(schedule),
            const SizedBox(height: 16),
            _buildFooter(totalInterest, totalPaid, tcea),
            const SizedBox(height: 16),
            _buildDisclaimer(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cronograma de Pagos',
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primaryContainer),
            ),
            Text('Detalle mensual del financiamiento vehicular',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(99)),
          child: const Row(
            children: [
              Icon(Icons.check_circle, size: 14, color: Color(0xFF16A34A)),
              SizedBox(width: 4),
              Text('SBS Compliant', style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Color(0xFF166534))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoanSummaryCard(SimulationResponse result) {
    return SectionCard(
      borderLeftColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('CLIENTE', style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onSurfaceVariant)),
                  Text('Cliente en Simulación', style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryContainer)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('VEHÍCULO', style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onSurfaceVariant)),
                  Text('Vehículo Simulado', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryContainer)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16, mainAxisSpacing: 12, childAspectRatio: 2.5,
            children: [
              _SummaryItem(label: 'Monto de Préstamo', value: 'S/ ${result.loanAmount.toStringAsFixed(2)}', valueColor: AppColors.primaryContainer),
              _SummaryItem(label: 'TIR Mensual', value: '${result.tirMonthly.toStringAsFixed(2)}%', valueColor: AppColors.primaryContainer),
              _SummaryItem(label: 'Plazo', value: '${result.schedule.length} meses', valueColor: AppColors.primaryContainer),
              _SummaryItem(label: 'Cuota Mensual', value: 'S/ ${result.monthlyPayment.toStringAsFixed(2)}', valueColor: AppColors.secondary),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.secondary),
              const SizedBox(width: 6),
              const Text('Próximo pago: 15 Oct 2025', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_outlined, size: 14),
                label: const Text('Descargar', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<ScheduleRowResponse> schedule) {
    if (schedule.isEmpty) return const SizedBox();

    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                _TableHeader('N°', flex: 1),
                _TableHeader('Saldo\nInicial', flex: 2),
                _TableHeader('Interés', flex: 2),
                _TableHeader('Amort.', flex: 2),
                _TableHeader('Cuota', flex: 2),
                _TableHeader('Saldo\nFinal', flex: 2),
              ],
            ),
          ),
          if (schedule.length > 5) ...[
            ...schedule.take(4).map((r) => _buildRow(r, false)),
            _buildEllipsisRow(schedule.length),
            _buildRow(schedule.last, true),
          ] else ...[
            ...schedule.map((r) => _buildRow(r, r == schedule.last)),
          ]
        ],
      ),
    );
  }

  Widget _buildRow(ScheduleRowResponse row, bool isLast) {
    return Container(
      color: isLast
          ? AppColors.primary.withValues(alpha: 0.05)
          : row.period.isEven
              ? AppColors.surfaceContainerLow.withValues(alpha: 0.3)
              : Colors.transparent,
      child: Row(
        children: [
          _TableCell('${row.period}', flex: 1, bold: true),
          _TableCell('S/\n${row.initialBalance.toStringAsFixed(0)}', flex: 2),
          _TableCell('S/\n${row.interest.toStringAsFixed(0)}', flex: 2),
          _TableCell('S/\n${row.amortization.toStringAsFixed(0)}', flex: 2),
          _TableCell('S/\n${row.totalPayment.toStringAsFixed(0)}', flex: 2, bold: true, boldColor: AppColors.primary),
          _TableCell('S/\n${row.finalBalance.toStringAsFixed(0)}', flex: 2, boldColor: isLast ? AppColors.secondary : null),
        ],
      ),
    );
  }

  Widget _buildEllipsisRow(int totalLength) {
    return Container(
      color: AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text('· · · Meses 5 a ${totalLength - 1} · · ·',
          style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.outlineVariant),
        ),
      ),
    );
  }

  Widget _buildFooter(double totalInterest, double totalPaid, double tcea) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FooterItem(label: 'Interés Total', value: 'S/ ${totalInterest.toStringAsFixed(2)}'),
          ),
          Expanded(
            child: _FooterItem(label: 'Total a Pagar', value: 'S/ ${totalPaid.toStringAsFixed(2)}'),
          ),
          Expanded(
            child: _FooterItem(label: 'TCEA Estimada', value: '${tcea.toStringAsFixed(2)}%', valueColor: AppColors.secondaryContainer),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outlined, size: 18, color: AppColors.primaryContainer),
              SizedBox(width: 6),
              Text('Consideraciones Importantes',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryContainer),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...[
            'El Seguro de Desgravamen se calcula como un monto fijo mensual en este simulador.',
            'Los cálculos son referenciales y sujetos a evaluación crediticia.',
            'El cronograma asume pagos puntuales cada 30 días.',
          ].map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                Flexible(child: Text(t, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String label;
  final int flex;
  const _TableHeader(this.label, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Text(
          label,
          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: AppColors.onPrimary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool bold;
  final Color? boldColor;
  const _TableCell(this.text, {required this.flex, this.bold = false, this.boldColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: boldColor ?? AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _SummaryItem({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.outline)),
        Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: valueColor, height: 1.2)),
      ],
    );
  }
}

class _FooterItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _FooterItem({required this.label, required this.value, this.valueColor = AppColors.onPrimary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onPrimary), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w700, color: valueColor), textAlign: TextAlign.center),
      ],
    );
  }
}
