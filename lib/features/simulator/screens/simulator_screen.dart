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
  String _gracePeriod = 'Parcial';
  int _graceMonths = 2;
  double _cok = 10;
  String _capitalization = 'Mensual (m=12)';

  bool _simulated = false;
  bool _isLoading = false;

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
        graceMonths: _graceMonths,
        cok: _cok,
      );

      final repo = ref.read(simulatorRepositoryProvider);
      final result = await repo.simulate(request);
      
      ref.read(simulationResultProvider.notifier).state = result;
      
      if (mounted) {
        setState(() => _simulated = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(simulationResultProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AutomaticsAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormCard(),
            const SizedBox(height: 20),
            if (result != null) ...[
              _buildResultsBanner(),
              const SizedBox(height: 16),
              _buildMetricsGrid(result),
              const SizedBox(height: 16),
              _buildScheduleSummary(context, result),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text('Simulador — Compra Inteligente',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.secondaryContainer.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.help_outline, size: 14, color: AppColors.secondary),
                    SizedBox(width: 4),
                    Text('Ayuda', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCurrencyToggle(),
          const SizedBox(height: 16),
          _buildNumberField('Precio del Vehículo *', _vehiclePrice, 'S/', (v) => setState(() => _vehiclePrice = v)),
          const SizedBox(height: 16),
          _buildSliderField(),
          const SizedBox(height: 16),
          _buildNumberField('Cuota Final Inteligente (%)', _finalPaymentPct, null, (v) => setState(() => _finalPaymentPct = v), suffix: '%'),
          const SizedBox(height: 16),
          _buildTermAndRateType(),
          const SizedBox(height: 16),
          _buildNumberField('Valor de la Tasa (%) *', _rateValue, null, (v) => setState(() => _rateValue = v), suffix: '%',
            helpText: 'TEM = (1 + TEA)^(1/12) − 1'),
          if (_rateType == 'TNA') ...[
            const SizedBox(height: 16),
            _buildCapitalizationField(),
          ],
          const SizedBox(height: 16),
          _buildGracePeriodSelector(),
          const SizedBox(height: 16),
          _buildGraceMonthsField(),
          const SizedBox(height: 16),
          _buildNumberField('Tasa de Descuento — COK (%)', _cok, null, (v) => setState(() => _cok = v), suffix: '%',
            helpText: 'Costo de Oportunidad del Capital. Usado para calcular el VAN.'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _simulate,
              icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onSecondary)) : const Icon(Icons.bolt, size: 18),
              label: Text(_isLoading ? 'Calculando...' : 'Simular Crédito'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyToggle() {
    return _formField(
      label: 'Moneda del Crédito *',
      helpText: 'Selecciona la moneda base del contrato.',
      child: Container(
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: ['SOLES', 'DÓLARES'].map((c) {
            final sel = _currency == c;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currency = c),
                child: Container(
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
                        color: sel ? AppColors.onSecondary : AppColors.onSurfaceVariant,
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

  Widget _buildNumberField(String label, double value, String? prefix, ValueChanged<double> onChanged, {String? suffix, String? helpText}) {
    return _formField(
      label: label,
      helpText: helpText,
      child: TextFormField(
        initialValue: value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (v) => onChanged(double.tryParse(v) ?? value),
        decoration: InputDecoration(
          prefixText: prefix != null ? '$prefix ' : null,
          prefixStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
          suffixText: suffix,
          suffixStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildSliderField() {
    return _formField(
      label: 'Cuota Inicial (%) *',
      helpText: 'Pago inicial al contado. Monto financiado = Precio − Cuota inicial.',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mín. 10%', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.onSurfaceVariant)),
              Text('${_initialPaymentPct.toInt()}% seleccionado', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
              const Text('Máx. 50%', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.onSurfaceVariant)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.secondary,
              inactiveTrackColor: AppColors.surfaceContainerHigh,
              thumbColor: AppColors.secondary,
              overlayColor: AppColors.secondary.withValues(alpha: 0.1),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
            child: Text(
              '${_currency == 'SOLES' ? 'S/' : 'US\$'} ${_initialPaymentAmt.toStringAsFixed(2)} (${_initialPaymentPct.toInt()}%)',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermAndRateType() {
    return Row(
      children: [
        Expanded(
          child: _formField(
            label: 'Plazo *',
            helpText: 'Meses de 30 días.',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _termMonths,
                  isExpanded: true,
                  items: [12, 24, 36, 48, 60, 72].map((m) => DropdownMenuItem(value: m, child: Text('$m', style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)))).toList(),
                  onChanged: (v) => setState(() => _termMonths = v!),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _formField(
            label: 'Tipo de Tasa *',
            helpText: 'TEA no requiere capitalización. TNA sí.',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _rateType,
                  isExpanded: true,
                  items: ['TEA', 'TNA'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.secondary)))).toList(),
                  onChanged: (v) => setState(() => _rateType = v!),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapitalizationField() {
    return _formField(
      label: 'Capitalización *',
      helpText: 'Solo requerido para TNA. Frecuencia de acumulación del interés.',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _capitalization,
            isExpanded: true,
            items: ['Mensual (m=12)', 'Trimestral (m=4)', 'Semestral (m=2)']
                .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontFamily: 'Inter', fontSize: 13))))
                .toList(),
            onChanged: (v) => setState(() => _capitalization = v!),
          ),
        ),
      ),
    );
  }

  Widget _buildGracePeriodSelector() {
    return _formField(
      label: 'Período de Gracia',
      helpText: 'Parcial: solo intereses. Total: intereses se capitalizan al saldo.',
      child: Row(
        children: ['Sin gracia', 'Parcial', 'Total'].map((g) {
          final sel = _gracePeriod == g;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => setState(() => _gracePeriod = g),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.secondary.withValues(alpha: 0.1) : Colors.transparent,
                    border: Border.all(
                      color: sel ? AppColors.secondary : AppColors.outlineVariant,
                      width: sel ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(g, style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w700, color: sel ? AppColors.secondary : AppColors.onSurface)),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGraceMonthsField() {
    return _formField(
      label: 'Meses de Gracia',
      helpText: 'Cantidad de meses iniciales con gracia.',
      child: Container(
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: AppColors.secondary),
              onPressed: () => setState(() => _graceMonths = (_graceMonths - 1).clamp(0, 12)),
            ),
            Expanded(
              child: Center(
                child: Text('$_graceMonths', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.secondary),
              onPressed: () => setState(() => _graceMonths = (_graceMonths + 1).clamp(0, 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField({required String label, required Widget child, String? helpText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 6),
        child,
        if (helpText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.info_outlined, size: 12, color: AppColors.secondary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(helpText, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.onSurfaceVariant)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildResultsBanner() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(99)),
            child: const Text('OFERTA RECOMENDADA', style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onSecondaryContainer)),
          ),
          const SizedBox(height: 6),
          const Text('Tu próximo vehículo está a un clic.',
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onPrimary, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(SimulationResponse result) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SectionCard(
                borderLeftColor: AppColors.secondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CUOTA MENSUAL', style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(children: [
                        const TextSpan(text: 'S/ ', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.onSurfaceVariant)),
                        TextSpan(text: result.monthlyPayment.toStringAsFixed(2), style: const TextStyle(fontFamily: 'Inter', fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.primary)),
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
                    const Text('CUOTA FINAL (BALLOON)', style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(children: [
                        const TextSpan(text: 'S/ ', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.onSurfaceVariant)),
                        TextSpan(text: result.balloonPayment.toStringAsFixed(2), style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.5,
          children: [
            _metricSmall('VAN (Deudor)', 'S/ ${result.van.toStringAsFixed(2)}'),
            _metricSmall('TIR Mensual', '${result.tirMonthly.toStringAsFixed(4)}%'),
            _metricSmall('TCEA', '${result.tcea.toStringAsFixed(2)}%', valueColor: AppColors.secondary),
            _metricSmall('Total Interés', 'S/ ${result.totalInterest.toStringAsFixed(2)}'),
          ],
        ),
      ],
    );
  }

  Widget _metricSmall(String label, String value, {Color valueColor = AppColors.primary}) {
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
          Text(label, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onSurfaceVariant)),
          Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildScheduleSummary(BuildContext context, SimulationResponse result) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Resumen del Cronograma', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.paymentSchedule),
                  child: const Icon(Icons.open_in_new, color: AppColors.onPrimary, size: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _summaryRow('Importe del Préstamo', 'S/ ${result.loanAmount.toStringAsFixed(2)}'),
                _summaryRow('Intereses Totales', 'S/ ${result.totalInterest.toStringAsFixed(2)}'),
                _summaryRow('Cuota Final Inteligente', 'S/ ${result.balloonPayment.toStringAsFixed(2)}'),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pago Total Estimado', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
                    Text('S/ ${result.totalPayment.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.paymentSchedule),
                    icon: const Icon(Icons.calendar_month_outlined, size: 16),
                    label: const Text('Ver Cronograma Completo'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.financialIndicators),
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

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ],
      ),
    );
  }
}

extension _PowDouble on double {
  double pow(num exponent) => math.pow(this, exponent).toDouble();
}
