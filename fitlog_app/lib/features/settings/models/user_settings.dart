class UserSettings {
  final String? gender;
  final double? height;
  final double? weight;
  final double? weeklyGoalHours;

  UserSettings({
    this.gender,
    this.height,
    this.weight,
    this.weeklyGoalHours,
  });

  UserSettings copyWith({
    String? gender,
    double? height,
    double? weight,
    double? weeklyGoalHours,
  }) {
    return UserSettings(
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      weeklyGoalHours: weeklyGoalHours ?? this.weeklyGoalHours,
    );
  }

  Map<String, dynamic> toJson() => {
        'gender': gender,
        'height': height,
        'weight': weight,
        'weeklyGoalHours': weeklyGoalHours,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        gender: json['gender'] as String?,
        height: (json['height'] as num?)?.toDouble(),
        weight: (json['weight'] as num?)?.toDouble(),
        weeklyGoalHours: (json['weeklyGoalHours'] as num?)?.toDouble(),
      );
}
