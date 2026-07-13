import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/nutrition_entities.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/nutrition_ai_datasource.dart';
import '../datasources/nutrition_remote_datasource.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final NutritionAiDataSource aiDataSource;
  final NutritionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final FirebaseAuth firebaseAuth;

  const NutritionRepositoryImpl({
    required this.aiDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.firebaseAuth,
  });

  String get _userId => firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<Either<Failure, NutritionAnalysisEntity>> analyzeFood(
    File imageFile,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final analysis = await aiDataSource.analyzeFood(imageFile, _userId);
      return Right(analysis);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, MealLogEntity>> logMeal(MealLogEntity meal) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final logged = await remoteDataSource.logMeal(meal);
      return Right(logged);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, DailySummaryEntity>> getDailySummary(
    String userId,
    DateTime date,
  ) async {
    try {
      final meals = await remoteDataSource.getMealLogs(userId, date);
      final consumed = meals.fold<NutritionSummaryEntity>(
        NutritionSummaryEntity.zero,
        (sum, meal) => sum + meal.totalNutrition,
      );
      return Right(DailySummaryEntity(
        userId: userId,
        date: date,
        consumed: consumed,
        target: const NutritionSummaryEntity(
          calories: AppConstants.defaultCalories,
          protein: AppConstants.defaultProtein,
          carbs: AppConstants.defaultCarbs,
          fats: AppConstants.defaultFats,
        ),
        meals: meals,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<MealLogEntity>>> getMealLogs(
    String userId,
    DateTime date,
  ) async {
    try {
      final meals = await remoteDataSource.getMealLogs(userId, date);
      return Right(meals);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<MealLogEntity>>> getMealHistory(
    String userId,
    DateTime from,
    DateTime to,
  ) async {
    try {
      final meals = await remoteDataSource.getMealHistory(userId, from, to);
      return Right(meals);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Stream<DailySummaryEntity?> watchDailySummary(String userId, DateTime date) {
    return remoteDataSource.watchMealLogs(userId, date).map((meals) {
      if (meals.isEmpty) return null;
      final consumed = meals.fold<NutritionSummaryEntity>(
        NutritionSummaryEntity.zero,
        (sum, meal) => sum + meal.totalNutrition,
      );
      return DailySummaryEntity(
        userId: userId,
        date: date,
        consumed: consumed,
        target: const NutritionSummaryEntity(
          calories: AppConstants.defaultCalories,
          protein: AppConstants.defaultProtein,
          carbs: AppConstants.defaultCarbs,
          fats: AppConstants.defaultFats,
        ),
        meals: meals,
      );
    });
  }
}
