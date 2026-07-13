import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile(String userId);
  Future<UserProfileModel> updateProfile(UserProfileEntity profile);
  Stream<UserProfileModel?> watchProfile(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProfileRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Future<UserProfileModel> getProfile(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (!doc.exists || doc.data() == null) {
        throw const ServerException(message: 'Profile not found');
      }
      return UserProfileModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get profile');
    }
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileEntity profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      await _users.doc(profile.userId).set(
            model.toFirestore(),
            SetOptions(merge: true),
          );
      final updatedDoc = await _users.doc(profile.userId).get();
      return UserProfileModel.fromFirestore(updatedDoc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update profile');
    }
  }

  @override
  Stream<UserProfileModel?> watchProfile(String userId) {
    return _users.doc(userId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserProfileModel.fromFirestore(snap);
    });
  }
}
