import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final String email;
  final String? photoUrl;
  final int? age;
  final double? weight; // kg
  final double? height; // cm
  final String? gender; // male, female, other
  final String? activityLevel; // sedentary, light, moderate, active, very_active
  final String? goal; // lose_weight, maintain, gain_muscle
  final double? dailyCaloriesTarget;
  final double? dailyProteinTarget;
  final double? dailyCarbsTarget;
  final double? dailyFatsTarget;
  final bool onboardingComplete;
  final DateTime? updatedAt;

  const UserProfileEntity({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.activityLevel,
    this.goal,
    this.dailyCaloriesTarget,
    this.dailyProteinTarget,
    this.dailyCarbsTarget,
    this.dailyFatsTarget,
    this.onboardingComplete = false,
    this.updatedAt,
  });

  double? get bmi {
    if (weight == null || height == null || height == 0) return null;
    final heightM = height! / 100;
    return weight! / (heightM * heightM);
  }

  UserProfileEntity copyWith({
    String? displayName,
    String? photoUrl,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? activityLevel,
    String? goal,
    double? dailyCaloriesTarget,
    double? dailyProteinTarget,
    double? dailyCarbsTarget,
    double? dailyFatsTarget,
    bool? onboardingComplete,
    DateTime? updatedAt,
  }) {
    return UserProfileEntity(
      id: id,
      userId: userId,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      dailyCaloriesTarget: dailyCaloriesTarget ?? this.dailyCaloriesTarget,
      dailyProteinTarget: dailyProteinTarget ?? this.dailyProteinTarget,
      dailyCarbsTarget: dailyCarbsTarget ?? this.dailyCarbsTarget,
      dailyFatsTarget: dailyFatsTarget ?? this.dailyFatsTarget,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, displayName, email, photoUrl, age, weight, height,
        gender, activityLevel, goal, dailyCaloriesTarget, dailyProteinTarget,
        dailyCarbsTarget, dailyFatsTarget, onboardingComplete, updatedAt,
      ];
}
