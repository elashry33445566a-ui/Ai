import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/nutrition_entities.dart';

abstract class NutritionRepository {
  Future<Either<Failure, NutritionAnalysisEntity>> analyzeFood(File imageFile);
  Future<Either<Failure, MealLogEntity>> logMeal(MealLogEntity meal);
  Future<Either<Failure, DailySummaryEntity>> getDailySummary(
      String userId, DateTime date);
  Future<Either<Failure, List<MealLogEntity>>> getMealLogs(
      String userId, DateTime date);
  Future<Either<Failure, List<MealLogEntity>>> getMealHistory(
      String userId, DateTime from, DateTime to);
  Stream<DailySummaryEntity?> watchDailySummary(String userId, DateTime date);
}
