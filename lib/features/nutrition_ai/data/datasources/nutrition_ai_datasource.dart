import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart' as app_errors;
import '../../domain/entities/nutrition_entities.dart';

abstract class NutritionAiDataSource {
  Future<NutritionAnalysisEntity> analyzeFood(File imageFile, String userId);
}

class NutritionAiDataSourceImpl implements NutritionAiDataSource {
  final GenerativeModel _model;
  final Uuid _uuid;

  NutritionAiDataSourceImpl({
    required GenerativeModel model,
    required Uuid uuid,
  })  : _model = model,
        _uuid = uuid;

  @override
  Future<NutritionAnalysisEntity> analyzeFood(
    File imageFile,
    String userId,
  ) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final prompt = _buildPrompt();

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ];

      final response = await _model.generateContent(content);
      final text = response.text;
      if (text == null || text.isEmpty) {
        throw const app_errors.ServerException(
            message: 'AI returned empty response');
      }

      return _parseResponse(text, userId, imageFile.path);
    } on app_errors.ServerException {
      rethrow;
    } catch (e) {
      throw app_errors.ServerException(
          message: 'Food analysis failed: ${e.toString()}');
    }
  }

  String _buildPrompt() {
    return '''
Analyze this food image and provide detailed nutritional information in JSON format.
Return ONLY valid JSON, no markdown, no code blocks.

Format:
{
  "detected_foods": [
    {
      "name": "Food Name",
      "serving_size_grams": 150,
      "confidence": 0.95,
      "nutrition": {
        "calories": 250,
        "protein": 20,
        "carbs": 30,
        "fats": 8,
        "fiber": 3,
        "sugar": 5,
        "sodium": 400
      }
    }
  ],
  "total_nutrition": {
    "calories": 250,
    "protein": 20,
    "carbs": 30,
    "fats": 8,
    "fiber": 3,
    "sugar": 5,
    "sodium": 400
  },
  "ai_insights": "Brief 2-3 sentence analysis of the meal's nutritional quality, what's good about it, and any suggestions.",
  "meal_type": "lunch"
}

Be accurate with nutritional values. Use standard serving sizes.
''';
  }

  NutritionAnalysisEntity _parseResponse(
    String text,
    String userId,
    String imagePath,
  ) {
    try {
      // Clean JSON – remove markdown if model adds it
      final cleaned =
          text.replaceAll('```json', '').replaceAll('```', '').trim();

      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      final detectedFoodsJson = json['detected_foods'] as List<dynamic>? ?? [];
      final detectedFoods = detectedFoodsJson.map((f) {
        final fm = f as Map<String, dynamic>;
        final nutritionMap = fm['nutrition'] as Map<String, dynamic>? ?? {};
        return FoodItemEntity(
          name: fm['name'] as String? ?? 'Unknown',
          servingSize: (fm['serving_size_grams'] as num?)?.toDouble() ?? 100,
          confidence: (fm['confidence'] as num?)?.toDouble() ?? 0.8,
          nutrition: _parseNutrition(nutritionMap),
        );
      }).toList();

      final totalJson = json['total_nutrition'] as Map<String, dynamic>? ?? {};
      final totalNutrition = _parseNutrition(totalJson);
      final insights =
          json['ai_insights'] as String? ?? 'Nutritional analysis complete.';
      final mealType = json['meal_type'] as String? ?? 'meal';

      return NutritionAnalysisEntity(
        id: _uuid.v4(),
        userId: userId,
        imageUrl: imagePath,
        detectedFoods: detectedFoods,
        totalNutrition: totalNutrition,
        aiInsights: insights,
        mealType: mealType,
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      throw app_errors.ServerException(
          message: 'Failed to parse AI response: ${e.toString()}');
    }
  }

  NutritionSummaryEntity _parseNutrition(Map<String, dynamic> map) {
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

  static GenerativeModel createModel() {
    return GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
    );
  }
}
