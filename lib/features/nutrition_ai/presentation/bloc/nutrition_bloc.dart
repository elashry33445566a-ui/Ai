import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/nutrition_entities.dart';
import '../../domain/usecases/nutrition_usecases.dart';
import '../../domain/repositories/nutrition_repository.dart';
import 'nutrition_event.dart';
import 'nutrition_state.dart';

class NutritionBloc extends Bloc<NutritionEvent, NutritionState> {
  final AnalyzeFoodUseCase analyzeFoodUseCase;
  final LogMealUseCase logMealUseCase;
  final GetDailySummaryUseCase getDailySummaryUseCase;
  final NutritionRepository nutritionRepository;
  final Uuid uuid;

  StreamSubscription? _summarySubscription;

  NutritionBloc({
    required this.analyzeFoodUseCase,
    required this.logMealUseCase,
    required this.getDailySummaryUseCase,
    required this.nutritionRepository,
    required this.uuid,
  }) : super(const NutritionInitial()) {
    on<AnalyzeFoodImage>(_onAnalyzeFood);
    on<LogAnalyzedMeal>(_onLogMeal);
    on<LoadDailySummary>(_onLoadDailySummary);
    on<WatchDailySummary>(_onWatchDailySummary);
    on<DailySummaryUpdated>(_onDailySummaryUpdated);
    on<ResetAnalysis>(_onReset);
  }

  Future<void> _onAnalyzeFood(
    AnalyzeFoodImage event,
    Emitter<NutritionState> emit,
  ) async {
    emit(const NutritionLoading(message: 'Analyzing your food with AI...'));
    final result = await analyzeFoodUseCase(AnalyzeFoodParams(event.imageFile));
    result.fold(
      (failure) => emit(NutritionError(failure.message)),
      (analysis) => emit(FoodAnalyzed(analysis)),
    );
  }

  Future<void> _onLogMeal(
    LogAnalyzedMeal event,
    Emitter<NutritionState> emit,
  ) async {
    emit(const NutritionLoading(message: 'Logging meal...'));
    final mealLog = MealLogEntity(
      id: uuid.v4(),
      userId: event.analysis.userId,
      analysisId: event.analysis.id,
      foods: event.analysis.detectedFoods,
      totalNutrition: event.analysis.totalNutrition,
      mealType: event.analysis.mealType,
      loggedAt: DateTime.now(),
      imageUrl: event.analysis.imageUrl,
    );
    final result = await logMealUseCase(mealLog);
    result.fold(
      (failure) => emit(NutritionError(failure.message)),
      (logged) => emit(MealLogged(logged)),
    );
  }

  Future<void> _onLoadDailySummary(
    LoadDailySummary event,
    Emitter<NutritionState> emit,
  ) async {
    emit(const NutritionLoading());
    final result = await getDailySummaryUseCase(
      GetDailySummaryParams(userId: event.userId, date: event.date),
    );
    result.fold(
      (failure) => emit(NutritionError(failure.message)),
      (summary) => emit(DailySummaryLoaded(summary)),
    );
  }

  Future<void> _onWatchDailySummary(
    WatchDailySummary event,
    Emitter<NutritionState> emit,
  ) async {
    await _summarySubscription?.cancel();
    emit(const NutritionLoading());
    await emit.forEach<DailySummaryEntity?>(
      nutritionRepository.watchDailySummary(event.userId, event.date),
      onData: (summary) => summary != null
          ? DailySummaryLoaded(summary)
          : const NutritionEmpty(),
      onError: (_, __) => const NutritionError('Failed to load daily summary'),
    );
  }

  void _onDailySummaryUpdated(
    DailySummaryUpdated event,
    Emitter<NutritionState> emit,
  ) {
    if (event.summary != null) {
      emit(DailySummaryLoaded(event.summary!));
    } else {
      emit(const NutritionEmpty());
    }
  }

  void _onReset(ResetAnalysis event, Emitter<NutritionState> emit) {
    emit(const NutritionInitial());
  }

  @override
  Future<void> close() {
    _summarySubscription?.cancel();
    return super.close();
  }
}
