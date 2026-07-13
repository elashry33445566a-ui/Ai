import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfileEntity>> getProfile(String userId);
  Future<Either<Failure, UserProfileEntity>> updateProfile(UserProfileEntity profile);
  Future<Either<Failure, UserProfileEntity>> completeOnboarding(UserProfileEntity profile);
  Stream<UserProfileEntity?> watchProfile(String userId);
}
