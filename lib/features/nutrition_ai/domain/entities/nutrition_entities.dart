import 'package:equatable/equatable.dart';

class NutritionAnalysisEntity extends Equatable {
  final String id;
  final String userId;
  final String imageUrl;
  final List<FoodItemEntity> detectedFoods;
  final NutritionSummaryEntity totalNutrition;
  final String aiInsights;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime analyzedAt;
  final bool isLogged;

  const NutritionAnalysisEntity({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.detectedFoods,
    required this.totalNutrition,
    required this.aiInsights,
    required this.mealType,
    required this.analyzedAt,
    this.isLogged = false,
  });

  @override
  List<Object?> get props => [
        id, userId, imageUrl, detectedFoods, totalNutrition,
        aiInsights, mealType, analyzedAt, isLogged,
      ];
}

class FoodItemEntity extends Equatable {
  final String name;
  final double servingSize; // grams
  final double confidence; // 0.0 - 1.0
  final NutritionSummaryEntity nutrition;

  const FoodItemEntity({
    required this.name,
    required this.servingSize,
    required this.confidence,
    required this.nutrition,
  });

  @override
  List<Object> get props => [name, servingSize, confidence, nutrition];
}

class NutritionSummaryEntity extends Equatable {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final double sugar;
  final double sodium;

  const NutritionSummaryEntity({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
  });

  NutritionSummaryEntity operator +(NutritionSummaryEntity other) {
    return NutritionSummaryEntity(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fats: fats + other.fats,
      fiber: fiber + other.fiber,
      sugar: sugar + other.sugar,
      sodium: sodium + other.sodium,
    );
  }

  static const NutritionSummaryEntity zero = NutritionSummaryEntity(
    calories: 0,
    protein: 0,
    carbs: 0,
    fats: 0,
  );

  @override
  List<Object> get props => [calories, protein, carbs, fats, fiber, sugar, sodium];
}

class MealLogEntity extends Equatable {
  final String id;
  final String userId;
  final String? analysisId;
  final List<FoodItemEntity> foods;
  final NutritionSummaryEntity totalNutrition;
  final String mealType;
  final DateTime loggedAt;
  final String? notes;
  final String? imageUrl;

  const MealLogEntity({
    required this.id,
    required this.userId,
    this.analysisId,
    required this.foods,
    required this.totalNutrition,
    required this.mealType,
    required this.loggedAt,
    this.notes,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id, userId, analysisId, foods, totalNutrition,
        mealType, loggedAt, notes, imageUrl,
      ];
}

class DailySummaryEntity extends Equatable {
  final String userId;
  final DateTime date;
  final NutritionSummaryEntity consumed;
  final NutritionSummaryEntity target;
  final List<MealLogEntity> meals;

  const DailySummaryEntity({
    required this.userId,
    required this.date,
    required this.consumed,
    required this.target,
    required this.meals,
  });

  double get caloriesRemaining => target.calories - consumed.calories;
  double get caloriesProgress =>
      target.calories > 0 ? (consumed.calories / target.calories).clamp(0.0, 1.0) : 0;

  @override
  List<Object> get props => [userId, date, consumed, target, meals];
}
