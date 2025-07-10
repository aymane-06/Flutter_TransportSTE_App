class DashboardStatsModel {
  final int totalTrips;
  final int ongoingTrips;
  final int completedTrips;
  final double totalExpenses;
  final List<RecentActivityModel> recentActivities;

  DashboardStatsModel({
    required this.totalTrips,
    required this.ongoingTrips,
    required this.completedTrips,
    required this.totalExpenses,
    required this.recentActivities,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalTrips: json['total_trips'] ?? 0,
      ongoingTrips: json['ongoing_trips'] ?? 0,
      completedTrips: json['completed_trips'] ?? 0,
      totalExpenses: (json['total_expenses'] ?? 0).toDouble(),
      recentActivities:
          (json['recent_activities'] as List<dynamic>?)
              ?.map((activity) => RecentActivityModel.fromJson(activity))
              .toList() ??
          [],
    );
  }

  List<Object?> get props => [
    totalTrips,
    ongoingTrips,
    completedTrips,
    totalExpenses,
    recentActivities,
  ];
}

class RecentActivityModel {
  final int id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String type;
  final String? iconName;

  RecentActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.type,
    this.iconName,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      type: json['type'] ?? 'general',
      iconName: json['icon_name'],
    );
  }
}
