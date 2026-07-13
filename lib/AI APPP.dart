import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/nutrition_ai/presentation/bloc/nutrition_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await configureDependencies();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const NutriClinicApp());
}

class NutriClinicApp extends StatelessWidget {
  const NutriClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide BLoCs at the root so every GoRouter route can access them.
    // AuthBloc is a singleton-like factory — one shared instance drives
    // the auth-state stream and the redirect guard in AppRouter.
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const CheckAuthStatus()),
          lazy: false, // start listening to auth stream immediately
        ),
        BlocProvider<NutritionBloc>(
          create: (_) => sl<NutritionBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'AI Nutrition Clinic',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
