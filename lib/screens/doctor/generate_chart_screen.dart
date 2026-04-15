import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/health_chart_model.dart';
import '../../models/child_model.dart';
import '../../services/database_service.dart';
import '../../services/gemini_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class GenerateChartScreen extends StatefulWidget {
  final int parentId;
  final int childId;
  final int doctorId;
  final String childName;

  const GenerateChartScreen({
    Key? key,
    required this.parentId,
    required this.childId,
    required this.doctorId,
    required this.childName,
  }) : super(key: key);

  @override
  State<GenerateChartScreen> createState() => _GenerateChartScreenState();
}

class _GenerateChartScreenState extends State<GenerateChartScreen> {
  final _dbService = DatabaseService.instance;
  final _requirementsController = TextEditingController();
  String _selectedChartType = AppConstants.chartTypeFood;
  bool _isGenerating = false;

  @override
  void dispose() {
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _generateChart() async {
    if (_requirementsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter requirements'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // Get child details for AI generation
      final child = await _dbService.getChildById(widget.childId);
      if (child == null) {
        throw Exception('Child not found');
      }

      // Generate chart using Gemini AI
      final generatedContent = await GeminiService.generateHealthChart(
        chartType: _selectedChartType,
        childName: child.name,
        childAge: child.age,
        requirements: _requirementsController.text.trim(),
      );

      // Store the generated content
      final chart = HealthChartModel(
        parentId: widget.parentId,
        doctorId: widget.doctorId,
        childId: widget.childId,
        chartType: _selectedChartType,
        chartData: generatedContent, // Store AI-generated content directly
        notes: _requirementsController.text.trim(),
      );

      await _dbService.createHealthChart(chart);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chart generated successfully with AI!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Map<String, dynamic> _generateSampleChartData(String chartType) {
    switch (chartType) {
      case AppConstants.chartTypeFood:
        return {
          'type': 'Weekly Food Chart',
          'items': [
            {'day': 'Monday', 'breakfast': 'Oatmeal with fruits', 'lunch': 'Rice with vegetables', 'dinner': 'Soup and bread'},
            {'day': 'Tuesday', 'breakfast': 'Eggs and toast', 'lunch': 'Pasta with chicken', 'dinner': 'Fish with salad'},
            {'day': 'Wednesday', 'breakfast': 'Pancakes', 'lunch': 'Sandwich', 'dinner': 'Rice and curry'},
            {'day': 'Thursday', 'breakfast': 'Cereal with milk', 'lunch': 'Pizza', 'dinner': 'Grilled chicken'},
            {'day': 'Friday', 'breakfast': 'Smoothie bowl', 'lunch': 'Fried rice', 'dinner': 'Pasta'},
            {'day': 'Saturday', 'breakfast': 'French toast', 'lunch': 'Burger', 'dinner': 'Stir fry'},
            {'day': 'Sunday', 'breakfast': 'Waffles', 'lunch': 'Roast chicken', 'dinner': 'Soup'},
          ],
        };
      case AppConstants.chartTypeMedicine:
        return {
          'type': 'Monthly Medicine Chart',
          'medicines': [
            {'name': 'Vitamin D', 'dosage': '1 tablet', 'frequency': 'Daily', 'time': 'Morning'},
            {'name': 'Multivitamin', 'dosage': '1 tablet', 'frequency': 'Daily', 'time': 'After breakfast'},
            {'name': 'Calcium', 'dosage': '1 tablet', 'frequency': 'Daily', 'time': 'Evening'},
          ],
          'notes': 'Continue for 30 days',
        };
      case AppConstants.chartTypeActivity:
        return {
          'type': 'Child Activity Chart',
          'activities': [
            {'time': '7:00 AM', 'activity': 'Wake up and morning routine'},
            {'time': '8:00 AM', 'activity': 'Breakfast'},
            {'time': '9:00 AM', 'activity': 'Playtime / Study'},
            {'time': '12:00 PM', 'activity': 'Lunch'},
            {'time': '1:00 PM', 'activity': 'Nap time'},
            {'time': '3:00 PM', 'activity': 'Outdoor play'},
            {'time': '6:00 PM', 'activity': 'Indoor activities'},
            {'time': '7:00 PM', 'activity': 'Dinner'},
            {'time': '8:00 PM', 'activity': 'Story time'},
            {'time': '9:00 PM', 'activity': 'Bedtime'},
          ],
        };
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Health Chart'),
        backgroundColor: AppColors.doctorColor,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.child_care, color: AppColors.primary, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Generating chart for:',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            widget.childName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Chart Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildChartTypeCard(
              AppConstants.chartTypeFood,
              'Weekly Food Chart',
              Icons.restaurant,
              'Generate a weekly meal plan',
            ),
            const SizedBox(height: 12),
            _buildChartTypeCard(
              AppConstants.chartTypeMedicine,
              'Monthly Medicine Chart',
              Icons.medication,
              'Create medicine schedule',
            ),
            const SizedBox(height: 12),
            _buildChartTypeCard(
              AppConstants.chartTypeActivity,
              'Child Activity Chart',
              Icons.directions_run,
              'Plan daily activities',
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _requirementsController,
              label: 'Requirements / Notes',
              hint: 'Enter specific requirements or preferences...',
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Generate Chart with ML',
              onPressed: _generateChart,
              isLoading: _isGenerating,
              backgroundColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeCard(String type, String title, IconData icon, String description) {
    final isSelected = _selectedChartType == type;
    return InkWell(
      onTap: () => setState(() => _selectedChartType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.greyLight,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.greyLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
