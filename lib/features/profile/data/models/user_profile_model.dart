import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.userId,
    required super.displayName,
    required super.email,
    super.photoUrl,
    super.age,
    super.weight,
    super.height,
    super.gender,
    super.activityLevel,
    super.goal,
    super.dailyCaloriesTarget,
    super.dailyProteinTarget,
    super.dailyCarbsTarget,
    super.dailyFatsTarget,
    super.onboardingComplete,
    super.updatedAt,
  });

  factory UserProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return UserProfileModel(
      id: doc.id,
      userId: data['userId'] as String? ?? doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      age: data['age'] as int?,
      weight: (data['weight'] as num?)?.toDouble(),
      height: (data['height'] as num?)?.toDouble(),
      gender: data['gender'] as String?,
      activityLevel: data['activityLevel'] as String?,
      goal: data['goal'] as String?,
      dailyCaloriesTarget: (data['dailyCaloriesTarget'] as num?)?.toDouble(),
      dailyProteinTarget: (data['dailyProteinTarget'] as num?)?.toDouble(),
      dailyCarbsTarget: (data['dailyCarbsTarget'] as num?)?.toDouble(),
      dailyFatsTarget: (data['dailyFatsTarget'] as num?)?.toDouble(),
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'activityLevel': activityLevel,
      'goal': goal,
      'dailyCaloriesTarget': dailyCaloriesTarget,
      'dailyProteinTarget': dailyProteinTarget,
      'dailyCarbsTarget': dailyCarbsTarget,
      'dailyFatsTarget': dailyFatsTarget,
      'onboardingComplete': onboardingComplete,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      userId: entity.userId,
      displayName: entity.displayName,
      email: entity.email,
      photoUrl: entity.photoUrl,
      age: entity.age,
      weight: entity.weight,
      height: entity.height,
      gender: entity.gender,
      activityLevel: entity.activityLevel,
      goal: entity.goal,
      dailyCaloriesTarget: entity.dailyCaloriesTarget,
      dailyProteinTarget: entity.dailyProteinTarget,
      dailyCarbsTarget: entity.dailyCarbsTarget,
      dailyFatsTarget: entity.dailyFatsTarget,
      onboardingComplete: entity.onboardingComplete,
      updatedAt: entity.updatedAt,
    );
  }
}
