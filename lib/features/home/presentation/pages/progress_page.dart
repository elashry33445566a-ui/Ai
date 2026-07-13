import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../nutrition_ai/presentation/bloc/nutrition_bloc.dart';
import '../../../nutrition_ai/presentation/bloc/nutrition_event.dart';
import '../../../nutrition_ai/presentation/bloc/nutrition_state.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthBloc is at the root. Provide a scoped NutritionBloc for this page.
    return BlocProvider<NutritionBloc>(
      create: (ctx) {
        final authState = ctx.read<AuthBloc>().state;
        final userId =
            authState is Authenticated ? authState.user.id : '';
        return sl<NutritionBloc>()
          ..add(LoadDailySummary(userId: userId, date: DateTime.now()));
      },
      child: const _ProgressView(),
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Progress'),
        backgroundColor: AppColors.backgroundDark,
      ),
      body: BlocBuilder<NutritionBloc, NutritionState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStreakCard(context),
                const SizedBox(height: 16),
                _buildWeeklyChart(context),
                const SizedBox(height: 16),
                _buildMacroDonut(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_rounded,
              color: Colors.black, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Day Streak',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              Text(
                '7 days 🔥',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    final bars = List.generate(7, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: (i % 3 == 0) ? 1800 : (i % 2 == 0 ? 2100 : 1600),
            width: 20,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });

    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Calories',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                barGroups: bars,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) => Text(
                        days[value.toInt()],
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                    ),
                  ),
                ),
                maxY: 2500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroDonut(BuildContext context, NutritionState state) {
    double protein = 0, carbs = 0, fats = 0;
    if (state is DailySummaryLoaded) {
      protein = state.summary.consumed.protein;
      carbs = state.summary.consumed.carbs;
      fats = state.summary.consumed.fats;
    }
    final total = protein + carbs + fats;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Macro Distribution",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: total == 0
                        ? [
                            PieChartSectionData(
                              value: 1,
                              color: AppColors.backgroundElevated,
                              title: '',
                              radius: 40,
                            )
                          ]
                        : [
                            PieChartSectionData(
                              value: protein,
                              color: AppColors.protein,
                              title:
                                  '${((protein / total) * 100).toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              radius: 40,
                            ),
                            PieChartSectionData(
                              value: carbs,
                              color: AppColors.carbs,
                              title:
                                  '${((carbs / total) * 100).toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              radius: 40,
                            ),
                            PieChartSectionData(
                              value: fats,
                              color: AppColors.fats,
                              title:
                                  '${((fats / total) * 100).toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              radius: 40,
                            ),
                          ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Legend('Protein', AppColors.protein,
                      '${protein.toStringAsFixed(0)}g'),
                  const SizedBox(height: 12),
                  _Legend('Carbs', AppColors.carbs,
                      '${carbs.toStringAsFixed(0)}g'),
                  const SizedBox(height: 12),
                  _Legend(
                      'Fats', AppColors.fats, '${fats.toStringAsFixed(0)}g'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  final String value;

  const _Legend(this.label, this.color, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11)),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}
