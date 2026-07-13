import 'package:equatable/equatable.dart';
import '../../domain/entities/nutrition_entities.dart';

abstract class NutritionState extends Equatable {
  const NutritionState();
  @override
  List<Object?> get props => [];
}

class NutritionInitial extends NutritionState {
  const NutritionInitial();
}

class NutritionLoading extends NutritionState {
  final String? message;
  const NutritionLoading({this.message});
  @override
  List<Object?> get props => [message];
}

class FoodAnalyzed extends NutritionState {
  final NutritionAnalysisEntity analysis;
  const FoodAnalyzed(this.analysis);
  @override
  List<Object> get props => [analysis];
}

class MealLogged extends NutritionState {
  final MealLogEntity meal;
  const MealLogged(this.meal);
  @override
  List<Object> get props => [meal];
}

class DailySummaryLoaded extends NutritionState {
  final DailySummaryEntity summary;
  const DailySummaryLoaded(this.summary);
  @override
  List<Object> get props => [summary];
}

class NutritionError extends NutritionState {
  final String message;
  const NutritionError(this.message);
  @override
  List<Object> get props => [message];
}

class NutritionEmpty extends NutritionState {
  const NutritionEmpty();
}
