class UserStats {
  final int exchangesThisMonth;
  final int exchangesLastMonth;
  final double hoursThisWeek;
  final double hoursLastWeek;

  const UserStats({
    required this.exchangesThisMonth,
    required this.exchangesLastMonth,
    required this.hoursThisWeek,
    required this.hoursLastWeek,
  });

  const UserStats.zero()
      : exchangesThisMonth = 0,
        exchangesLastMonth = 0,
        hoursThisWeek = 0.0,
        hoursLastWeek = 0.0;

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      exchangesThisMonth: (json['exchangesThisMonth'] ?? 0) as int,
      exchangesLastMonth: (json['exchangesLastMonth'] ?? 0) as int,
      hoursThisWeek: (json['hoursThisWeek'] ?? 0).toDouble(),
      hoursLastWeek: (json['hoursLastWeek'] ?? 0).toDouble(),
    );
  }
}

