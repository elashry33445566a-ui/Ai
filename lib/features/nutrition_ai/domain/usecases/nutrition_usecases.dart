import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/nutrition_entities.dart';
import '../repositories/nutrition_repository.dart';

class AnalyzeFoodUseCase implements UseCase<NutritionAnalysisEntity, AnalyzeFoodParams> {
  final NutritionRepository repository;

  const AnalyzeFoodUseCase(this.repository);

  @override
  Future<Either<Failure, NutritionAnalysisEntity>> call(AnalyzeFoodParams params) {
    return repository.analyzeFood(params.imageFile);
  }
}

class AnalyzeFoodParams {
  final File imageFile;
  const AnalyzeFoodParams(this.imageFile);
}

class LogMealUseCase implements UseCase<MealLogEntity, MealLogEntity> {
  final NutritionRepository repository;

  const LogMealUseCase(this.repository);

  @override
  Future<Either<Failure, MealLogEntity>> call(MealLogEntity params) {
    return repository.logMeal(params);
  }
}

class GetDailySummaryParams {
  final String userId;
  final DateTime date;
  const GetDailySummaryParams({required this.userId, required this.date});
}

class GetDailySummaryUseCase
    implements UseCase<DailySummaryEntity, GetDailySummaryParams> {
  final NutritionRepository repository;

  const GetDailySummaryUseCase(this.repository);

  @override
  Future<Either<Failure, DailySummaryEntity>> call(GetDailySummaryParams params) {
    return repository.getDailySummary(params.userId, params.date);
  }
}
