import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/nutrition_entities.dart';

abstract class NutritionEvent extends Equatable {
  const NutritionEvent();
  @override
  List<Object?> get props => [];
}

class AnalyzeFoodImage extends NutritionEvent {
  final File imageFile;
  const AnalyzeFoodImage(this.imageFile);
  @override
  List<Object> get props => [imageFile];
}

class LogAnalyzedMeal extends NutritionEvent {
  final NutritionAnalysisEntity analysis;
  const LogAnalyzedMeal(this.analysis);
  @override
  List<Object> get props => [analysis];
}

class LoadDailySummary extends NutritionEvent {
  final String userId;
  final DateTime date;
  const LoadDailySummary({required this.userId, required this.date});
  @override
  List<Object> get props => [userId, date];
}

class WatchDailySummary extends NutritionEvent {
  final String userId;
  final DateTime date;
  const WatchDailySummary({required this.userId, required this.date});
  @override
  List<Object> get props => [userId, date];
}

class DailySummaryUpdated extends NutritionEvent {
  final DailySummaryEntity? summary;
  const DailySummaryUpdated(this.summary);
  @override
  List<Object?> get props => [summary];
}

class ResetAnalysis extends NutritionEvent {
  const ResetAnalysis();
}
