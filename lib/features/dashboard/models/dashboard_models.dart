class DashboardResponse {
  final int totalClients;
  final int activeContracts;
  final int inEvaluation;
  final int withOverdue;
  final double totalFinanced;
  final double approvalRate;
  final List<RecentActivityResponse> recentActivity;

  final List<double> vanHistory;
  final List<String> vanLabels;
  final List<double> tirHistory;
  final List<String> tirLabels;

  DashboardResponse({
    required this.totalClients,
    required this.activeContracts,
    required this.inEvaluation,
    required this.withOverdue,
    required this.totalFinanced,
    required this.approvalRate,
    required this.recentActivity,
    required this.vanHistory,
    required this.vanLabels,
    required this.tirHistory,
    required this.tirLabels,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      totalClients:    (json['totalClientes']        as num?)?.toInt()    ?? (json['totalClients']          as num?)?.toInt()    ?? 0,
      activeContracts: (json['creditosActivos']       as num?)?.toInt()    ?? (json['activeContracts']        as num?)?.toInt()    ?? 0,
      inEvaluation:    (json['enEvaluacion']          as num?)?.toInt()    ?? (json['inEvaluation']           as num?)?.toInt()    ?? 0,
      withOverdue:     (json['conMora']               as num?)?.toInt()    ?? (json['withOverdue']            as num?)?.toInt()    ?? 0,
      totalFinanced:   (json['montoTotalFinanciado']  as num?)?.toDouble() ?? (json['totalFinanced']          as num?)?.toDouble() ?? 0.0,
      approvalRate:    (json['tasaAprobacion']        as num?)?.toDouble() ?? (json['approvalRate']           as num?)?.toDouble() ?? 0.0,

      vanHistory: (json['vanHistory'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [0.0, 0.0, 0.0, 0.0],
      vanLabels:  (json['vanLabels'] as List?)?.map((e) => e.toString()).toList() ?? ['M1', 'M2', 'M3', 'M4'],

      tirHistory: (json['tirHistory'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [0.5, 0.5, 0.5, 0.5],
      tirLabels:  (json['tirLabels'] as List?)?.map((e) => e.toString()).toList() ?? ['S1', 'S2', 'S3', 'S4'],

      recentActivity: json['recentActivity'] != null
          ? (json['recentActivity'] as List).map((e) => RecentActivityResponse.fromJson(e as Map<String, dynamic>)).toList()
          : json['actividadReciente'] != null
          ? (json['actividadReciente'] as List).map((e) => RecentActivityResponse.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

class RecentActivityResponse {
  final int id; // ✨ NUEVO
  final String clientName;
  final String description;
  final double amount;
  final String timeAgo;

  RecentActivityResponse({
    required this.id, // ✨ NUEVO
    required this.clientName,
    required this.description,
    required this.amount,
    required this.timeAgo,
  });

  factory RecentActivityResponse.fromJson(Map<String, dynamic> json) {
    return RecentActivityResponse(
      id:          (json['id']         as num?)?.toInt() ?? 0, // ✨ NUEVO
      clientName:  json['clientName']  as String? ?? json['nombreCliente'] as String? ?? '',
      description: json['description'] as String? ?? json['descripcion']  as String? ?? '',
      amount:      (json['amount']     as num?)?.toDouble() ?? (json['monto']      as num?)?.toDouble() ?? 0.0,
      timeAgo:     json['timeAgo']     as String? ?? json['hace']        as String? ?? '',
    );
  }
}