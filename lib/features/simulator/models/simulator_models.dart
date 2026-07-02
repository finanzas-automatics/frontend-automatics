class SimulationRequest {
  final String currency;
  final double vehiclePrice;
  final double initialPaymentPct;
  final double finalPaymentPct;
  final int termMonths;
  final String rateType;
  final double rateValue;
  final String? capitalization;
  final String gracePeriodType;
  final int graceMonths;
  final double cok;
  final int clienteId;
  final int vehiculoId;
  final int usuarioId;

  SimulationRequest({
    required this.currency,
    required this.vehiclePrice,
    required this.initialPaymentPct,
    required this.finalPaymentPct,
    required this.termMonths,
    required this.rateType,
    required this.rateValue,
    this.capitalization,
    required this.gracePeriodType,
    required this.graceMonths,
    required this.cok,
    this.clienteId  = 0,
    this.vehiculoId = 0,
    this.usuarioId  = 0,
  });

  Map<String, dynamic> toJson() => {
    'clienteId':              clienteId,
    'vehiculoId':             vehiculoId,
    'usuarioId':              usuarioId,
    'precioVenta':            vehiclePrice,
    'moneda':                 currency,
    'porcentajeCuotaInicial': initialPaymentPct / 100,
    'plazoMeses':             termMonths,
    'tasaInteresAnual':       rateValue / 100,
    'esTasaEfectiva':         rateType == 'TEA',
    'diasCapitalizacion':     rateType == 'TNA' ? 30 : 0,
    'mesesGraciaTotal':       gracePeriodType == 'total'   ? graceMonths : 0,
    'mesesGraciaParcial':     gracePeriodType == 'parcial' ? graceMonths : 0,
    'porcentajeCuotaFinal':   finalPaymentPct / 100,
    'tasaDesgravamenMensual': 0.00049,
    'seguroVehicularMensual': 0.00030,
    'portesMensuales':        3.50,
    'tasaCokAnual':           cok / 100,
  };
}

class SimulationResponse {
  final int id;
  final double loanAmount;
  final double initialPayment;
  final double balloonPayment;
  final double monthlyPayment;
  final double temMonthly;
  final double tirMonthly;
  final double tcea;
  final double van;
  final double totalInterest;
  final double totalPayment;
  final List<ScheduleRowResponse> schedule;

  SimulationResponse({
    required this.id,
    required this.loanAmount,
    required this.initialPayment,
    required this.balloonPayment,
    required this.monthlyPayment,
    required this.temMonthly,
    required this.tirMonthly,
    required this.tcea,
    required this.van,
    required this.totalInterest,
    required this.totalPayment,
    required this.schedule,
  });

  factory SimulationResponse.fromJson(Map<String, dynamic> json) {
    final List cronograma = (json['cronogramaPagos'] ?? json['schedule'] ?? []) as List;
    final schedule = cronograma
        .map((e) => ScheduleRowResponse.fromJson(e as Map<String, dynamic>))
        .toList();

    final totalInterest = schedule.fold(0.0, (sum, r) => sum + r.interest);
    final totalPayment  = schedule.fold(0.0, (sum, r) => sum + r.totalPayment);

    // Funciones a prueba de balas para evitar el error Type 'Null' is not a subtype
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return SimulationResponse(
      id:             parseId(json['id']),
      loanAmount:     parseDouble(json['montoPrestamo']),
      initialPayment: 0.0,
      balloonPayment: schedule.isNotEmpty ? schedule.last.totalPayment : 0.0,
      monthlyPayment: schedule.isNotEmpty ? schedule.first.totalPayment : 0.0,
      temMonthly:     parseDouble(json['valorTasa']),
      tirMonthly:     parseDouble(json['indicadorTIR']),
      tcea:           parseDouble(json['indicadorTCEA']),
      van:            parseDouble(json['indicadorVAN']),
      totalInterest:  totalInterest,
      totalPayment:   totalPayment,
      schedule:       schedule,
    );
  }
}

class ScheduleRowResponse {
  final int period;
  final double initialBalance;
  final double interest;
  final double amortization;
  final double insurance;
  final double totalPayment;
  final double finalBalance;
  final String graceType;

  ScheduleRowResponse({
    required this.period,
    required this.initialBalance,
    required this.interest,
    required this.amortization,
    required this.insurance,
    required this.totalPayment,
    required this.finalBalance,
    required this.graceType,
  });

  factory ScheduleRowResponse.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return ScheduleRowResponse(
      period:         (json['numeroMes'] as num?)?.toInt() ?? 0,
      initialBalance: parseDouble(json['saldoInicial']),
      interest:       parseDouble(json['interes']),
      amortization:   parseDouble(json['amortizacion']),
      insurance:      parseDouble(json['segurosYGastos']),
      totalPayment:   parseDouble(json['cuotaTotalMensual']),
      finalBalance:   parseDouble(json['saldoFinal']),
      graceType:      json['tipoPeriodo'] as String? ?? '',
    );
  }
}