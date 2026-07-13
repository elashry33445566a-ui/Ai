import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/nutrition_bloc.dart';
import '../bloc/nutrition_event.dart';
import '../bloc/nutrition_state.dart';
import '../widgets/analysis_result_widget.dart';

class NutritionAnalysisPage extends StatefulWidget {
  const NutritionAnalysisPage({super.key});

  @override
  State<NutritionAnalysisPage> createState() =>
      _NutritionAnalysisPageState();
}

class _NutritionAnalysisPageState extends State<NutritionAnalysisPage> {
  File? _selectedImage;
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    // Provide a fresh NutritionBloc scoped to this analysis flow.
    return BlocProvider<NutritionBloc>(
      create: (_) => sl<NutritionBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: const Text(AppStrings.aiAnalysis),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<NutritionBloc, NutritionState>(
          listener: (context, state) {
            if (state is MealLogged) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.mealLogged),
                  backgroundColor: AppColors.success,
                ),
              );
              context.go('/home');
            } else if (state is NutritionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is NutritionLoading) {
              return _buildLoadingView(state.message);
            }
            if (state is FoodAnalyzed) {
              return AnalysisResultWidget(
                analysis: state.analysis,
                onLog: () => context
                    .read<NutritionBloc>()
                    .add(LogAnalyzedMeal(state.analysis)),
                onRetake: () {
                  setState(() => _selectedImage = null);
                  context
                      .read<NutritionBloc>()
                      .add(const ResetAnalysis());
                },
              );
            }
            return _buildCaptureView(context);
          },
        ),
      ),
    );
  }

  Widget _buildCaptureView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildImagePreview(),
          const SizedBox(height: 32),
          _buildCaptureButtons(context),
          if (_selectedImage != null) ...[
            const SizedBox(height: 24),
            _buildAnalyzeButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: _selectedImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(_selectedImage!, fit: BoxFit.cover),
            )
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined,
                    color: AppColors.textMuted, size: 64),
                SizedBox(height: 16),
                Text(
                  AppStrings.captureFood,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Take a photo or choose from gallery',
                  style:
                      TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ],
            ),
    );
  }

  Widget _buildCaptureButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.black),
            label: const Text('Camera'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            if (_selectedImage != null) {
              context
                  .read<NutritionBloc>()
                  .add(AnalyzeFoodImage(_selectedImage!));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.auto_awesome_rounded, color: Colors.black),
          label: const Text(
            AppStrings.analyze,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.black,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            message ?? AppStrings.analyzing,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }
}
