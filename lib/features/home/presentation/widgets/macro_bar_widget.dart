import 'package:flutter/material.dart';
import '../../../nutrition_ai/domain/entities/nutrition_entities.dart';
import '../../../../core/constants/app_colors.dart';

class MacroBarWidget extends StatelessWidget {
  final DailySummaryEntity? summary;

  const MacroBarWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final protein = summary?.consumed.protein ?? 0;
    final carbs = summary?.consumed.carbs ?? 0;
    final fats = summary?.consumed.fats ?? 0;
    final proteinTarget = summary?.target.protein ?? 150;
    final carbsTarget = summary?.target.carbs ?? 250;
    final fatsTarget = summary?.target.fats ?? 65;

    return Row(
      children: [
        Expanded(
          child: _MacroCard(
            label: 'Protein',
            value: protein,
            target: proteinTarget,
            unit: 'g',
            color: AppColors.protein,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MacroCard(
            label: 'Carbs',
            value: carbs,
            target: carbsTarget,
            unit: 'g',
            color: AppColors.carbs,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MacroCard(
            label: 'Fats',
            value: fats,
            target: fatsTarget,
            unit: 'g',
            color: AppColors.fats,
          ),
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final double target;
  final String unit;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${value.toStringAsFixed(0)}$unit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.backgroundElevated,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
          const SizedBox(height: 4),
          Text(
            '/ ${target.toStringAsFixed(0)}$unit',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
