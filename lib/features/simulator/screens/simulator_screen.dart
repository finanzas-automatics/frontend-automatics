import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/simulator_provider.dart';
import '../models/simulator_models.dart';
import '../../clients/models/client_models.dart';
import '../../clients/providers/client_provider.dart';
import '../repositories/simulator_repository.dart';

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

  String _rateType = 'TNA';
  double _rateValue = 15;

  // ✨ CORRECCIÓN DE CAPITALIZACIÓN: Ahora dice "Diario"
  String _capitalization = 'Diario';

  String _gracePeriod = 'Sin gracia';
  int _graceMonths = 0;
  double _cok = 10;

  int _selectedClienteId = 0;
  int _selectedVehiculoId = 0;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  // ✨ GASTOS PERIÓDICOS EN CERO (Por defecto)
  double _tasaDesgravamenMensual = 0.0;
  double _seguroVehicularMensual = 0.0;
  double _portesMensuales = 0.0;
  double _gpsMensual = 0.0;
  double _gastosAdmMensuales = 0.0;

  // ✨ GASTOS INICIALES EN CERO (Por defecto)
  double _costesNotariales = 0.0;
  double _costesRegistrales = 0.0;
  double _tasacion = 0.0;
  double _comisionEstudio = 0.0;
  double _comisionActivacion = 0.0;

  // ✨ FINANCIAMIENTO DE GASTOS DESACTIVADO (Por defecto)
  bool _financiarNotariales = false;
  bool _financiarRegistrales = false;
  bool _financiarTasacion = false;
  bool _financiarEstudio = false;
  bool _financiarActivacion = false;

  String get _currencySymbol => _currency == 'SOLES' ? 'S/' : 'US\$';
  double get _initialPaymentAmt => _vehiclePrice * _initialPaymentPct / 100;

  Future<void> _simulate() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa los campos marcados en rojo antes de simular.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final usuarioId = await ref.read(currentUserIdProvider.future);
      final request = SimulationRequest(
        clienteId: _selectedClienteId,
        usuarioId: usuarioId,
        vehiculoId: _selectedVehiculoId,
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
        tasaDesgravamenMensual: _tasaDesgravamenMensual,
        seguroVehicularMensual: _seguroVehicularMensual,
        portesMensuales: _portesMensuales,
        gpsMensual: _gpsMensual,
        gastosAdmMensuales: _gastosAdmMensuales,
        costesNotariales: _costesNotariales,
        costesRegistrales: _costesRegistrales,
        tasacion: _tasacion,
        comisionEstudio: _comisionEstudio,
        comisionActivacion: _comisionActivacion,
        financiarNotariales: _financiarNotariales,
        financiarRegistrales: _financiarRegistrales,
        financiarTasacion: _financiarTasacion,
        financiarEstudio: _financiarEstudio,
        financiarActivacion: _financiarActivacion,
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
              _buildRiskBanner(result),
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
      child: Form(
        key: _formKey,
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

            _buildClientSearchDropdown(),

            const SizedBox(height: 16),
            _buildCurrencyToggle(),
            const SizedBox(height: 16),

            _buildField(
              label: 'Precio del Vehículo *',
              helpText: 'Se obtiene automáticamente del vehículo del cliente seleccionado.',
              child: TextFormField(
                key: ValueKey(_vehiclePrice),
                initialValue: '$_currencySymbol ${_vehiclePrice.toStringAsFixed(2)}',
                readOnly: true,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.outline),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                ),
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
                min: 0,
                max: 99,
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
                min: 0.01,
                max: 100,
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
                min: 0,
                max: 100,
                onChanged: (v) => setState(() => _cok = v),
              ),
            ),
            const SizedBox(height: 16),

            _buildAdvancedSettingsAccordion(),

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
      ),
    );
  }

  Widget _buildRiskBanner(SimulationResponse result) {
    if (result.riskClassification.isEmpty) return const SizedBox();

    final isAlto = result.riskClassification.contains('Alto');
    final isMedio = result.riskClassification.contains('Medio');
    final color = isAlto ? AppColors.error : (isMedio ? const Color(0xFFEAB308) : const Color(0xFF16A34A));
    final icon = isAlto ? Icons.warning_amber_rounded : (isMedio ? Icons.info_outline : Icons.check_circle_outline);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.riskClassification,
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                Text(result.riskDecision,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _helpChip() {
    return GestureDetector(
      onTap: _showSimulatorHelp,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.secondaryContainer.withValues(alpha: 0.3)),
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
      ),
    );
  }

  void _showSimulatorHelp() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Guía del Simulador', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              _HelpItem(term: 'TEA / TNA', desc: 'Tasa Efectiva Anual (ya incluye capitalización) o Tasa Nominal Anual (necesita indicar cómo se capitaliza).'),
              SizedBox(height: 10),
              _HelpItem(term: 'Capitalización', desc: 'Frecuencia con la que se acumulan intereses cuando usas TNA (diaria o mensual).'),
              SizedBox(height: 10),
              _HelpItem(term: 'Cuota Final Inteligente', desc: 'Pago único al final del plazo que reduce tus cuotas mensuales durante todo el crédito.'),
              SizedBox(height: 10),
              _HelpItem(term: 'Período de Gracia', desc: 'Parcial: solo pagas intereses. Total: los intereses se acumulan al saldo, sin pago mensual.'),
              SizedBox(height: 10),
              _HelpItem(term: 'COK', desc: 'Costo de Oportunidad del Capital — tasa usada para calcular el VAN de la operación.'),
              SizedBox(height: 10),
              _HelpItem(term: 'VAN', desc: 'Valor Actual Neto del préstamo, desde el punto de vista del deudor.'),
              SizedBox(height: 10),
              _HelpItem(term: 'TIR / TCEA', desc: 'TIR: tasa interna de retorno mensual del flujo. TCEA: TIR anualizada — el costo real total del crédito.'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido')),
        ],
      ),
    );
  }

  Widget _buildCurrencyToggle() {
    final bool isLocked = _selectedClienteId != 0 && _vehiclePrice > 0;

    return _buildField(
      label: 'Moneda del Crédito *',
      helpText: isLocked
          ? 'Moneda fijada automáticamente según el vehículo del cliente.'
          : 'Selecciona la moneda base del contrato.',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: ['SOLES', 'DÓLARES'].map((c) {
            final String currentNorm = _currency.toUpperCase().replaceAll('Ó', 'O');
            final String btnNorm = c.toUpperCase().replaceAll('Ó', 'O');
            final bool sel = currentNorm == btnNorm;

            return Expanded(
              child: GestureDetector(
                onTap: isLocked ? null : () => setState(() => _currency = c),
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
                            : AppColors.onSurfaceVariant.withValues(alpha: isLocked ? 0.4 : 1.0),
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

  Widget _buildClientSearchDropdown() {
    final clientsAsync = ref.watch(clientsListProvider);

    return _buildField(
      label: 'Cliente a Evaluar',
      helpText: 'Busca un cliente registrado por su nombre. Si lo dejas en blanco, será una simulación anónima.',
      child: clientsAsync.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error al cargar clientes: $err', style: const TextStyle(color: AppColors.error)),
        data: (pagedData) {
          final clients = pagedData.items;

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownMenu<int>(
              width: MediaQuery.of(context).size.width - 32,
              hintText: 'Escribe para buscar...',
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              inputDecorationTheme: const InputDecorationTheme(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onSelected: (int? newId) {
                if (newId != null) {
                  final selectedClient = clients.firstWhere((c) => c.id == newId);

                  setState(() {
                    _selectedClienteId = newId;
                    _selectedVehiculoId = selectedClient.vehicleId ?? 0;

                    if (selectedClient.vehiclePrice != null) {
                      _vehiclePrice = selectedClient.vehiclePrice!;
                    } else {
                      _vehiclePrice = 0.0;
                    }

                    if (selectedClient.vehicleCurrency != null) {
                      _currency = selectedClient.vehicleCurrency!;
                    }
                  });
                }
              },
              dropdownMenuEntries: clients.map((client) {
                return DropdownMenuEntry<int>(
                  value: client.id,
                  label: client.fullName,
                  style: MenuItemButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(fontFamily: 'Inter'),
                  ),
                );
              }).toList(),
            ),
          );
        },
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
        // ✨ Opciones corregidas a Diario / Mensual
        items: const ['Diario', 'Mensual'],
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
    int maxDecimals = 2,
    double? min,
    double? max,
  }) {
    return TextFormField(
      key: ValueKey(value),
      initialValue: value == value.truncate()
          ? value.toInt().toString()
          : value.toStringAsFixed(maxDecimals == 2 ? 2 : 4).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), ""),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'^\d*\.?\d{0,' + maxDecimals.toString() + r'}'),
        ),
      ],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (v) {
        final parsed = double.tryParse(v ?? '');
        if (parsed == null) return 'Ingresa un número válido';
        if (min != null && parsed < min) return 'Mínimo $min';
        if (max != null && parsed > max) return 'Máximo $max';
        return null;
      },
      onChanged: (v) {
        final parsed = double.tryParse(v);
        if (parsed != null) onChanged(parsed);
      },
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      decoration: InputDecoration(
        prefixText: prefix != null ? '$prefix ' : null,
        prefixStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
        suffixText: suffix,
        suffixStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
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
          label: 'TIR (mensual)',
          value: '${(result.tirMonthly).toStringAsFixed(4)}%',
        ),
        _metricChip(
          label: 'TCEA (Costo Real)',
          value: '${result.tcea.toStringAsFixed(4)}%',
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

  // ✨ WIDGET DE CONFIGURACIÓN AVANZADA
  Widget _buildAdvancedSettingsAccordion() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: const Text(
            '⚙️ Costos y Configuración Avanzada',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.outline,
          initiallyExpanded: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GASTOS INICIALES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  _buildGastoInicialRow('Costes Notariales', _costesNotariales, _financiarNotariales, (v) => setState(() => _costesNotariales = v), (v) => setState(() => _financiarNotariales = v)),
                  const SizedBox(height: 8),
                  _buildGastoInicialRow('Costes Registrales', _costesRegistrales, _financiarRegistrales, (v) => setState(() => _costesRegistrales = v), (v) => setState(() => _financiarRegistrales = v)),
                  const SizedBox(height: 8),
                  _buildGastoInicialRow('Tasación', _tasacion, _financiarTasacion, (v) => setState(() => _tasacion = v), (v) => setState(() => _financiarTasacion = v)),
                  const SizedBox(height: 8),
                  _buildGastoInicialRow('Comisión de Estudio', _comisionEstudio, _financiarEstudio, (v) => setState(() => _comisionEstudio = v), (v) => setState(() => _financiarEstudio = v)),
                  const SizedBox(height: 8),
                  _buildGastoInicialRow('Comisión Activación', _comisionActivacion, _financiarActivacion, (v) => setState(() => _comisionActivacion = v), (v) => setState(() => _financiarActivacion = v)),

                  const Divider(height: 30),
                  const Text('GASTOS PERIÓDICOS (MENSUALES)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _buildField(label: 'GPS (S/)', child: _numericInput(value: _gpsMensual, onChanged: (v) => setState(() => _gpsMensual = v)))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField(label: 'Gastos Adm. (S/)', child: _numericInput(value: _gastosAdmMensuales, onChanged: (v) => setState(() => _gastosAdmMensuales = v)))),
                    ],
                  ),

                  const Divider(height: 30),
                  const Text('SEGUROS Y PORTES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _buildField(label: '% Seg. Desgrav.', child: _numericInput(value: _tasaDesgravamenMensual, suffix: '%', maxDecimals: 4, min: 0, max: 5, onChanged: (v) => setState(() => _tasaDesgravamenMensual = v)))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField(label: '% Seg. Riesgo', child: _numericInput(value: _seguroVehicularMensual, suffix: '%', maxDecimals: 4, min: 0, max: 5, onChanged: (v) => setState(() => _seguroVehicularMensual = v)))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildField(label: 'Portes Físicos (S/)', child: _numericInput(value: _portesMensuales, onChanged: (v) => setState(() => _portesMensuales = v))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGastoInicialRow(String label, double value, bool isFinanced, ValueChanged<double> onChanged, ValueChanged<bool> onSwitch) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _buildField(
              label: label,
              child: _numericInput(value: value, onChanged: onChanged)
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(isFinanced ? 'Financiar' : 'Al Contado', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isFinanced ? AppColors.secondary : AppColors.onSurfaceVariant)),
              Switch(
                value: isFinanced,
                activeColor: AppColors.secondary,
                onChanged: onSwitch,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension on double {
  int truncate() => toInt();
}


class _HelpItem extends StatelessWidget {
  final String term;
  final String desc;
  const _HelpItem({required this.term, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(term, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
        Text(desc, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}