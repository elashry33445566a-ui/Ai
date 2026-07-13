import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/nutrition_entities.dart';
import '../models/meal_log_model.dart';

abstract class NutritionRemoteDataSource {
  Future<MealLogModel> logMeal(MealLogEntity meal);
  Future<List<MealLogModel>> getMealLogs(String userId, DateTime date);
  Future<List<MealLogModel>> getMealHistory(
      String userId, DateTime from, DateTime to);
  Stream<List<MealLogModel>> watchMealLogs(String userId, DateTime date);
}

class NutritionRemoteDataSourceImpl implements NutritionRemoteDataSource {
  final FirebaseFirestore _firestore;

  NutritionRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _mealsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('meals');

  @override
  Future<MealLogModel> logMeal(MealLogEntity meal) async {
    try {
      final model = MealLogModel.fromEntity(meal);
      final docRef = _mealsRef(meal.userId).doc(meal.id);
      await docRef.set(model.toFirestore());
      final snap = await docRef.get();
      return MealLogModel.fromFirestore(snap);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to log meal');
    }
  }

  @override
  Future<List<MealLogModel>> getMealLogs(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final query = await _mealsRef(userId)
          .where('loggedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('loggedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('loggedAt', descending: false)
          .get();

      return query.docs.map((doc) => MealLogModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get meals');
    }
  }

  @override
  Future<List<MealLogModel>> getMealHistory(
    String userId,
    DateTime from,
    DateTime to,
  ) async {
    try {
      final query = await _mealsRef(userId)
          .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
          .where('loggedAt', isLessThan: Timestamp.fromDate(to))
          .orderBy('loggedAt', descending: true)
          .get();

      return query.docs.map((doc) => MealLogModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Failed to get meal history');
    }
  }

  @override
  Stream<List<MealLogModel>> watchMealLogs(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _mealsRef(userId)
        .where('loggedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('loggedAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('loggedAt')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MealLogModel.fromFirestore(doc)).toList());
  }
}
