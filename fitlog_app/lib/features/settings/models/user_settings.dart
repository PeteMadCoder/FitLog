class UserSettings {
  final String? gender;
  final double? height;
  final double? weight;

  UserSettings({
    this.gender,
    this.height,
    this.weight,
  });

  UserSettings copyWith({
    String? gender,
    double? height,
    double? weight,
  }) {
    return UserSettings(
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toJson() => {
        'gender': gender,
        'height': height,
        'weight': weight,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        gender: json['gender'] as String?,
        height: (json['height'] as num?)?.toDouble(),
        weight: (json['weight'] as num?)?.toDouble(),
      );
}
