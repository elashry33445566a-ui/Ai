import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../nutrition_ai/presentation/bloc/nutrition_bloc.dart';
import '../../../nutrition_ai/presentation/bloc/nutrition_event.dart';
import '../../../nutrition_ai/presentation/bloc/nutrition_state.dart';
import '../widgets/calorie_ring_widget.dart';
import '../widgets/macro_bar_widget.dart';
import '../widgets/meal_card_widget.dart';
import '../widgets/quick_add_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthBloc is provided at the app root.
    // Provide a fresh NutritionBloc scoped to the home screen so it starts
    // watching today's meals as soon as the user arrives.
    return BlocProvider<NutritionBloc>(
      create: (ctx) {
        final authState = ctx.read<AuthBloc>().state;
        final userId =
            authState is Authenticated ? authState.user.id : '';
        return sl<NutritionBloc>()
          ..add(WatchDailySummary(userId: userId, date: DateTime.now()));
      },
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          final authState = context.read<AuthBloc>().state;
          final userId =
              authState is Authenticated ? authState.user.id : '';
          context.read<NutritionBloc>().add(
                WatchDailySummary(userId: userId, date: DateTime.now()),
              );
        },
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildGreetingSection(context),
                  const SizedBox(height: 24),
                  _buildCalorieSection(context),
                  const SizedBox(height: 24),
                  _buildMacroSection(context),
                  const SizedBox(height: 32),
                  _buildMealLogSection(context),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark,
      pinned: true,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_dining_rounded,
                color: Colors.black, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline_rounded),
          onPressed: () => context.push('/profile'),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: () =>
              context.read<AuthBloc>().add(const SignOutRequested()),
        ),
      ],
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = state is Authenticated
            ? state.user.displayName ?? 'there'
            : 'there';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_greeting()}, $name 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalorieSection(BuildContext context) {
    return BlocBuilder<NutritionBloc, NutritionState>(
      builder: (context, state) {
        if (state is DailySummaryLoaded) {
          return CalorieRingWidget(summary: state.summary);
        }
        return const CalorieRingWidget(summary: null);
      },
    );
  }

  Widget _buildMacroSection(BuildContext context) {
    return BlocBuilder<NutritionBloc, NutritionState>(
      builder: (context, state) {
        if (state is DailySummaryLoaded) {
          return MacroBarWidget(summary: state.summary);
        }
        return const MacroBarWidget(summary: null);
      },
    );
  }

  Widget _buildMealLogSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.mealLog,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton.icon(
              onPressed: () => context.push('/analyze'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(AppStrings.addMeal),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<NutritionBloc, NutritionState>(
          builder: (context, state) {
            if (state is DailySummaryLoaded &&
                state.summary.meals.isNotEmpty) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.summary.meals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) =>
                    MealCardWidget(meal: state.summary.meals[i]),
              );
            }
            if (state is NutritionLoading) {
              return _buildLoadingShimmer();
            }
            return _buildEmptyMeals(context);
          },
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(
        2,
        (_) => Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMeals(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.restaurant_menu_rounded,
              color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            'No meals logged yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to analyze and log your food',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: QuickAddButton(onPressed: () => context.push('/analyze')),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        switch (index) {
          case 1:
            context.push('/analyze');
          case 2:
            context.push('/progress');
          case 3:
            context.push('/profile');
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.camera_alt_outlined),
          selectedIcon: Icon(Icons.camera_alt_rounded),
          label: 'Analyze',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart_rounded),
          label: 'Progress',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outlined),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
