import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../network/network_info.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/nutrition_ai/data/datasources/nutrition_ai_datasource.dart';
import '../../features/nutrition_ai/data/datasources/nutrition_remote_datasource.dart';
import '../../features/nutrition_ai/data/repositories/nutrition_repository_impl.dart';
import '../../features/nutrition_ai/domain/repositories/nutrition_repository.dart';
import '../../features/nutrition_ai/domain/usecases/nutrition_usecases.dart';
import '../../features/nutrition_ai/presentation/bloc/nutrition_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ─── External ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.createInstance(),
  );
  sl.registerLazySingleton<GenerativeModel>(
    () => GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
    ),
  );
  sl.registerLazySingleton<Uuid>(() => const Uuid());

  // ─── Core ────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
  );

  // ─── Auth ────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => SignInUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()));
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl<SignInUseCase>(),
      signUpUseCase: sl<SignUpUseCase>(),
      signOutUseCase: sl<SignOutUseCase>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // ─── Profile ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );

  // ─── Nutrition AI ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NutritionAiDataSource>(
    () => NutritionAiDataSourceImpl(
      model: sl<GenerativeModel>(),
      uuid: sl<Uuid>(),
    ),
  );
  sl.registerLazySingleton<NutritionRemoteDataSource>(
    () => NutritionRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<NutritionRepository>(
    () => NutritionRepositoryImpl(
      aiDataSource: sl<NutritionAiDataSource>(),
      remoteDataSource: sl<NutritionRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      firebaseAuth: sl<FirebaseAuth>(),
    ),
  );
  sl.registerLazySingleton(
    () => AnalyzeFoodUseCase(sl<NutritionRepository>()),
  );
  sl.registerLazySingleton(
    () => LogMealUseCase(sl<NutritionRepository>()),
  );
  sl.registerLazySingleton(
    () => GetDailySummaryUseCase(sl<NutritionRepository>()),
  );
  sl.registerFactory(
    () => NutritionBloc(
      analyzeFoodUseCase: sl<AnalyzeFoodUseCase>(),
      logMealUseCase: sl<LogMealUseCase>(),
      getDailySummaryUseCase: sl<GetDailySummaryUseCase>(),
      nutritionRepository: sl<NutritionRepository>(),
      uuid: sl<Uuid>(),
    ),
  );
}
