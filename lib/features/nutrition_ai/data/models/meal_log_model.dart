import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/nutrition_entities.dart';

class MealLogModel extends MealLogEntity {
  const MealLogModel({
    required super.id,
    required super.userId,
    super.analysisId,
    required super.foods,
    required super.totalNutrition,
    required super.mealType,
    required super.loggedAt,
    super.notes,
    super.imageUrl,
  });

  factory MealLogModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final foodsList = (data['foods'] as List<dynamic>? ?? [])
        .map((f) => _parseFoodItem(f as Map<String, dynamic>))
        .toList();

    return MealLogModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      analysisId: data['analysisId'] as String?,
      foods: foodsList,
      totalNutrition: _parseNutrition(
        data['totalNutrition'] as Map<String, dynamic>? ?? {},
      ),
      mealType: data['mealType'] as String? ?? 'meal',
      loggedAt: (data['loggedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'] as String?,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'analysisId': analysisId,
      'foods': foods
          .map((f) => {
                'name': f.name,
                'servingSize': f.servingSize,
                'confidence': f.confidence,
                'nutrition': {
                  'calories': f.nutrition.calories,
                  'protein': f.nutrition.protein,
                  'carbs': f.nutrition.carbs,
                  'fats': f.nutrition.fats,
                  'fiber': f.nutrition.fiber,
                  'sugar': f.nutrition.sugar,
                  'sodium': f.nutrition.sodium,
                },
              })
          .toList(),
      'totalNutrition': {
        'calories': totalNutrition.calories,
        'protein': totalNutrition.protein,
        'carbs': totalNutrition.carbs,
        'fats': totalNutrition.fats,
        'fiber': totalNutrition.fiber,
        'sugar': totalNutrition.sugar,
        'sodium': totalNutrition.sodium,
      },
      'mealType': mealType,
      'loggedAt': Timestamp.fromDate(loggedAt),
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  factory MealLogModel.fromEntity(MealLogEntity entity) {
    return MealLogModel(
      id: entity.id,
      userId: entity.userId,
      analysisId: entity.analysisId,
      foods: entity.foods,
      totalNutrition: entity.totalNutrition,
      mealType: entity.mealType,
      loggedAt: entity.loggedAt,
      notes: entity.notes,
      imageUrl: entity.imageUrl,
    );
  }

  static FoodItemEntity _parseFoodItem(Map<String, dynamic> map) {
    return FoodItemEntity(
      name: map['name'] as String? ?? 'Unknown',
      servingSize: (map['servingSize'] as num?)?.toDouble() ?? 100,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 1.0,
      nutrition: _parseNutrition(map['nutrition'] as Map<String, dynamic>? ?? {}),
    );
  }

  static NutritionSummaryEntity _parseNutrition(Map<String, dynamic> map) {
    return NutritionSummaryEntity(
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
      fats: (map['fats'] as num?)?.toDouble() ?? 0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0,
      sugar: (map['sugar'] as num?)?.toDouble() ?? 0,
      sodium: (map['sodium'] as num?)?.toDouble() ?? 0,
    );
  }
}
