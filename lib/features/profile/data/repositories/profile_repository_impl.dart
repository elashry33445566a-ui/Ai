import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  const ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserProfileEntity>> getProfile(String userId) async {
    try {
      final profile = await remoteDataSource.getProfile(userId);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateProfile(
      UserProfileEntity profile) async {
    try {
      final updated = await remoteDataSource.updateProfile(profile);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> completeOnboarding(
      UserProfileEntity profile) async {
    try {
      final completed = await remoteDataSource
          .updateProfile(profile.copyWith(onboardingComplete: true));
      return Right(completed);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Stream<UserProfileEntity?> watchProfile(String userId) {
    return remoteDataSource.watchProfile(userId);
  }
}
