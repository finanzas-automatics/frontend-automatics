import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../providers/simulator_provider.dart';
import '../models/simulator_models.dart';

class SimulatorScreen extends ConsumerStatefulWidget {
  const SimulatorScreen({super.key});

  @override
  ConsumerState<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends ConsumerState<SimulatorScreen> {
  String _currency = 'SOLES';
  double _vehiclePrice = 45000;
  double _initialPaymentPct = 20;
  double _finalPaymentPct = 30;
  int _termMonths = 36;
  String _rateType = 'TEA';
  double _rateValue = 15;
  String _gracePeriod = 'Sin gracia';
  int _graceMonths = 0;
  double _cok = 10;
  String _capitalization = 'Mensual (m=12)';

  bool _isLoading = false;

  String get _currencySymbol => _currency == 'SOLES' ? 'S/' : 'US\$';
  double get _initialPaymentAmt => _vehiclePrice * _initialPaymentPct / 100;

  Future<void> _simulate() async {
    setState(() => _isLoading = true);
    try {
      final request = SimulationRequest(
        currency: _currency,
        vehiclePrice: _vehiclePrice,
        initialPaymentPct: _initialPaymentPct,
        finalPaymentPct: _finalPaymentPct,
        termMonths: _termMonths,
        rateType: _rateType,
        rateValue: _rateValue,
        capitalization: _rateType == 'TNA' ? _capitalization : null,
        gracePeriodType: _gracePeriod,
        graceMonths: _gracePeriod == 'Sin gracia' ? 0 : _graceMonths,
        cok: _cok,
      );
      final repo = ref.read(simulatorRepositoryProvider);
      final result = await repo.simulate(request);
      ref.read(simulationResultProvider.notifier).state = result;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(simulationResultProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AutomaticsAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormCard(),
            const SizedBox(height: 20),
            if (result != null) ...[
              _buildResultsBanner(),
              const SizedBox(height: 16),
              _buildMainMetrics(result),
              const SizedBox(height: 12),
              _buildSecondaryMetrics(result),
              const SizedBox(height: 16),
              _buildScheduleSummary(context, result),
            ],
          ],
        ),
      ),
    );
  }

  // ── FORM ──────────────────────────────────────────────────────────────────

  Widget _buildFormCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Simulador — Compra Inteligente',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              _helpChip(),
            ],
          ),
          const SizedBox(height: 20),
          _buildCurrencyToggle(),
          const SizedBox(height: 16),
          _buildField(
            label: 'Precio del Vehículo *',
            child: _numericInput(
              value: _vehiclePrice,
              prefix: _currencySymbol,
              onChanged: (v) => setState(() => _vehiclePrice = v),
            ),
          ),
          const SizedBox(height: 16),
          _buildSliderField(),
          const SizedBox(height: 16),
          _buildField(
            label: 'Cuota Final Inteligente (%)',
            child: _numericInput(
              value: _finalPaymentPct,
              suffix: '%',
              onChanged: (v) => setState(() => _finalPaymentPct = v),
            ),
          ),
          const SizedBox(height: 16),
          _buildTermAndRateRow(),
          const SizedBox(height: 16),
          _buildField(
            label: 'Valor de la Tasa (%) *',
            helpText: _rateType == 'TEA'
                ? 'TEM = (1 + TEA)^(1/12) − 1'
                : 'TNA capitalizable según frecuencia seleccionada.',
            child: _numericInput(
              value: _rateValue,
              suffix: '%',
              onChanged: (v) => setState(() => _rateValue = v),
            ),
          ),
          if (_rateType == 'TNA') ...[
            const SizedBox(height: 16),
            _buildCapitalizationDropdown(),
          ],
          const SizedBox(height: 16),
          _buildGracePeriodSelector(),
          if (_gracePeriod != 'Sin gracia') ...[
            const SizedBox(height: 16),
            _buildGraceMonthsStepper(),
          ],
          const SizedBox(height: 16),
          _buildField(
            label: 'Tasa de Descuento — COK (%)',
            helpText: 'Costo de Oportunidad del Capital. Usado para calcular el VAN.',
            child: _numericInput(
              value: _cok,
              suffix: '%',
              onChanged: (v) => setState(() => _cok = v),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _simulate,
              icon: _isLoading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.onSecondary),
              )
                  : const Icon(Icons.bolt_rounded, size: 18),
              label: Text(_isLoading ? 'Calculando...' : 'Simular Crédito'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _helpChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.1),
        border:
        Border.all(color: AppColors.secondaryContainer.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.help_outline, size: 13, color: AppColors.secondary),
          SizedBox(width: 4),
          Text(
            'Ayuda',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyToggle() {
    return _buildField(
      label: 'Moneda del Crédito *',
      helpText: 'Selecciona la moneda base del contrato.',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: ['SOLES', 'DÓLARES'].map((c) {
            final sel = _currency == c;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currency = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.secondary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      c == 'SOLES' ? 'S/ Soles' : 'US\$ Dólares',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: sel
                            ? AppColors.onSecondary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSliderField() {
    return _buildField(
      label: 'Cuota Inicial (%) *',
      helpText: 'Pago inicial al contado. Monto financiado = Precio − Cuota inicial.',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mín. 10%',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant)),
              Text(
                '${_initialPaymentPct.toInt()}% seleccionado',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              const Text('Máx. 50%',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.secondary,
              inactiveTrackColor: AppColors.surfaceContainerHigh,
              thumbColor: AppColors.secondary,
              overlayColor: AppColors.secondary.withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: _initialPaymentPct,
              min: 10,
              max: 50,
              divisions: 8,
              onChanged: (v) => setState(() => _initialPaymentPct = v),
            ),
          ),
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$_currencySymbol ${_initialPaymentAmt.toStringAsFixed(2)} (${_initialPaymentPct.toInt()}%)',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermAndRateRow() {
    return Row(
      children: [
        Expanded(
          child: _buildField(
            label: 'Plazo *',
            helpText: 'Meses de 30 días.',
            child: _dropdown<int>(
              value: _termMonths,
              items: [12, 24, 36, 48, 60, 72],
              labelBuilder: (m) => '$m',
              onChanged: (v) => setState(() => _termMonths = v),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildField(
            label: 'Tipo de Tasa *',
            helpText: 'TEA no requiere capitalización. TNA sí.',
            child: _dropdown<String>(
              value: _rateType,
              items: const ['TEA', 'TNA'],
              labelBuilder: (t) => t,
              onChanged: (v) => setState(() => _rateType = v),
              textColor: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapitalizationDropdown() {
    return _buildField(
      label: 'Capitalización *',
      helpText: 'Frecuencia de acumulación del interés para TNA.',
      child: _dropdown<String>(
        value: _capitalization,
        items: const [
          'Mensual (m=12)',
          'Trimestral (m=4)',
          'Semestral (m=2)'
        ],
        labelBuilder: (c) => c,
        onChanged: (v) => setState(() => _capitalization = v),
      ),
    );
  }

  Widget _buildGracePeriodSelector() {
    return _buildField(
      label: 'Período de Gracia',
      helpText:
      'Parcial: solo intereses. Total: intereses se capitalizan al saldo.',
      child: Row(
        children: ['Sin gracia', 'Parcial', 'Total'].map((g) {
          final sel = _gracePeriod == g;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => setState(() => _gracePeriod = g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.secondary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    border: Border.all(
                      color: sel
                          ? AppColors.secondary
                          : AppColors.outlineVariant,
                      width: sel ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      g,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: sel
                            ? AppColors.secondary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGraceMonthsStepper() {
    return _buildField(
      label: 'Meses de Gracia',
      helpText: 'Cantidad de meses iniciales con gracia (máx. 6).',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: AppColors.secondary, size: 22),
              onPressed: () =>
                  setState(() => _graceMonths = (_graceMonths - 1).clamp(1, 6)),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '$_graceMonths',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: AppColors.secondary, size: 22),
              onPressed: () =>
                  setState(() => _graceMonths = (_graceMonths + 1).clamp(1, 6)),
            ),
          ],
        ),
      ),
    );
  }

  // ── FIELD HELPERS ─────────────────────────────────────────────────────────

  Widget _buildField(
      {required String label, required Widget child, String? helpText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        child,
        if (helpText != null) ...[
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(Icons.info_outlined,
                    size: 12, color: AppColors.secondary),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  helpText,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _numericInput({
    required double value,
    String? prefix,
    String? suffix,
    required ValueChanged<double> onChanged,
  }) {
    return TextFormField(
      key: ValueKey(value),
      initialValue: value == value.truncate()
          ? value.toInt().toString()
          : value.toStringAsFixed(2),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (v) => onChanged(double.tryParse(v) ?? value),
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      decoration: InputDecoration(
        prefixText: prefix != null ? '$prefix ' : null,
        prefixStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant),
        suffixText: suffix,
        suffixStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onChanged,
    Color textColor = AppColors.primary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items
              .map((i) => DropdownMenuItem(
            value: i,
            child: Text(
              labelBuilder(i),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ))
              .toList(),
          onChanged: (v) => onChanged(v as T),
        ),
      ),
    );
  }

  // ── RESULTS ───────────────────────────────────────────────────────────────

  Widget _buildResultsBanner() {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryContainer, Color(0xFF1A3A6E)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'OFERTA RECOMENDADA',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: AppColors.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tu próximo vehículo está a un clic.',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMetrics(SimulationResponse result) {
    final sym = _currencySymbol;
    return Row(
      children: [
        Expanded(
          child: SectionCard(
            borderLeftColor: AppColors.secondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CUOTA MENSUAL',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: '$sym ',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant),
                    ),
                    TextSpan(
                      text: result.monthlyPayment.toStringAsFixed(2),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CUOTA FINAL (BALLOON)',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: '$sym ',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant),
                    ),
                    TextSpan(
                      text: result.balloonPayment.toStringAsFixed(2),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryMetrics(SimulationResponse result) {
    final sym = _currencySymbol;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: [
        _metricChip(
          label: 'VAN (Deudor)',
          value: '$sym ${result.van.toStringAsFixed(0)}',
          valueColor: result.van < 0 ? AppColors.error : AppColors.secondary,
        ),
        _metricChip(
          label: 'TIR (% anual)',
          value: '${(result.tirMonthly).toStringAsFixed(2)}%',
        ),
        _metricChip(
          label: 'TCEA (Costo Real)',
          value: '${result.tcea.toStringAsFixed(2)}%',
          valueColor: AppColors.secondary,
        ),
        _metricChip(
          label: 'Total Intereses',
          value: '$sym ${result.totalInterest.toStringAsFixed(0)}',
        ),
      ],
    );
  }

  Widget _metricChip({
    required String label,
    required String value,
    Color valueColor = AppColors.primary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSummary(
      BuildContext context, SimulationResponse result) {
    final sym = _currencySymbol;
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Dark header
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Resumen del Cronograma',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.paymentSchedule),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.download_outlined,
                        color: AppColors.onPrimary, size: 16),
                  ),
                ),
              ],
            ),
          ),
          // Summary rows
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _summaryRow('Importe del Préstamo',
                    '$sym ${result.loanAmount.toStringAsFixed(2)}'),
                _summaryRow('Intereses Totales',
                    '$sym ${result.totalInterest.toStringAsFixed(2)}'),
                _summaryRow('Pago Total Estimado',
                    '$sym ${result.totalPayment.toStringAsFixed(2)}',
                    bold: true,
                    valueColor: AppColors.secondary),
                const Divider(height: 20),
                // CTA buttons
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.go(AppRoutes.paymentSchedule),
                    icon: const Icon(Icons.table_chart_outlined, size: 16),
                    label: const Text('Ver Cronograma Completo'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.go(AppRoutes.financialIndicators),
                    icon: const Icon(Icons.analytics_outlined, size: 16),
                    label: const Text('Ver Indicadores Financieros'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String label,
      String value, {
        bool bold = false,
        Color valueColor = AppColors.primary,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.onSurfaceVariant),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: bold ? 'Montserrat' : 'Inter',
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
extension on double {
  int truncate() => toInt();
}