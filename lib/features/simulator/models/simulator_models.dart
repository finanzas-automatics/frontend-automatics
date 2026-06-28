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
  });

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'vehiclePrice': vehiclePrice,
        'initialPaymentPct': initialPaymentPct,
        'finalPaymentPct': finalPaymentPct,
        'termMonths': termMonths,
        'rateType': rateType,
        'rateValue': rateValue,
        if (capitalization != null) 'capitalization': capitalization,
        'gracePeriodType': gracePeriodType,
        'graceMonths': graceMonths,
        'cok': cok,
      };
}

class SimulationResponse {
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
    return SimulationResponse(
      loanAmount: (json['loanAmount'] as num).toDouble(),
      initialPayment: (json['initialPayment'] as num).toDouble(),
      balloonPayment: (json['balloonPayment'] as num).toDouble(),
      monthlyPayment: (json['monthlyPayment'] as num).toDouble(),
      temMonthly: (json['tea'] as num).toDouble(),
      tirMonthly: (json['tirMonthly'] as num).toDouble(),
      tcea: (json['tcea'] as num).toDouble(),
      van: (json['van'] as num).toDouble(),
      totalInterest: (json['totalInterest'] as num).toDouble(),
      totalPayment: (json['totalPayment'] as num).toDouble(),
      schedule: (json['schedule'] as List)
          .map((e) => ScheduleRowResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
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
    return ScheduleRowResponse(
      period: json['month'] as int,
      initialBalance: (json['initialBalance'] as num).toDouble(),
      interest: (json['interest'] as num).toDouble(),
      amortization: (json['amortization'] as num).toDouble(),
      insurance: (json['insurance'] as num).toDouble(),
      totalPayment: (json['totalPayment'] as num).toDouble(),
      finalBalance: (json['finalBalance'] as num).toDouble(),
      graceType: json['graceLabel'] as String,
    );
  }
}
