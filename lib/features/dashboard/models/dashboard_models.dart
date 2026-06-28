class DashboardResponse {
  final int totalClients;
  final int activeContracts;
  final int inEvaluation;
  final int withOverdue;
  final double totalFinanced;
  final double approvalRate;
  final List<RecentActivityResponse> recentActivity;

  DashboardResponse({
    required this.totalClients,
    required this.activeContracts,
    required this.inEvaluation,
    required this.withOverdue,
    required this.totalFinanced,
    required this.approvalRate,
    required this.recentActivity,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      totalClients: json['totalClients'] as int,
      activeContracts: json['activeContracts'] as int,
      inEvaluation: json['inEvaluation'] as int,
      withOverdue: json['withOverdue'] as int,
      totalFinanced: (json['totalFinanced'] as num).toDouble(),
      approvalRate: (json['approvalRate'] as num).toDouble(),
      recentActivity: (json['recentActivity'] as List)
          .map((e) => RecentActivityResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RecentActivityResponse {
  final String clientName;
  final String description;
  final double amount;
  final String timeAgo;

  RecentActivityResponse({
    required this.clientName,
    required this.description,
    required this.amount,
    required this.timeAgo,
  });

  factory RecentActivityResponse.fromJson(Map<String, dynamic> json) {
    return RecentActivityResponse(
      clientName: json['clientName'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      timeAgo: json['timeAgo'] as String,
    );
  }
}
