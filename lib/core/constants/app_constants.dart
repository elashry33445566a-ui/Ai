class AppConstants {
  AppConstants._();

  // AI
  static const String geminiModel = 'gemini-1.5-flash';
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY'; // TODO: Move to env

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String mealsCollection = 'meals';
  static const String plansCollection = 'nutrition_plans';
  static const String progressCollection = 'progress';

  // Hive Boxes
  static const String userBox = 'user_box';
  static const String mealsBox = 'meals_box';
  static const String settingsBox = 'settings_box';

  // SharedPreferences Keys
  static const String isLoggedIn = 'is_logged_in';
  static const String isOnboardingComplete = 'is_onboarding_complete';
  static const String userId = 'user_id';

  // UI
  static const double borderRadius = 16.0;
  static const double cardElevation = 0.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double iconSize = 24.0;
  static const double appBarHeight = 60.0;

  // Nutrition Defaults (daily targets)
  static const double defaultCalories = 2000.0;
  static const double defaultProtein = 150.0;
  static const double defaultCarbs = 250.0;
  static const double defaultFats = 65.0;
  static const double defaultFiber = 30.0;
  static const double defaultWater = 2500.0; // ml

  // Animation durations
  static const int animationDuration = 300;
  static const int longAnimationDuration = 600;
}
