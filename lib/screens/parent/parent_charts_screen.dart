import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/health_chart_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class ParentChartsScreen extends StatefulWidget {
  const ParentChartsScreen({Key? key}) : super(key: key);

  @override
  State<ParentChartsScreen> createState() => _ParentChartsScreenState();
}

class _ParentChartsScreenState extends State<ParentChartsScreen> {
  final _authService = AuthService();
  final _dbService = DatabaseService.instance;
  List<HealthChartModel> _charts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharts();
  }

  Future<void> _loadCharts() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final parent = await _dbService.getParentByUserId(userId);
        if (parent != null) {
          final charts = await _dbService.getChartsByParentId(parent.id!);
          setState(() {
            _charts = charts;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading charts: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _showChartDetails(HealthChartModel chart) {
    // Try to parse as JSON first, if it fails, treat as plain text (AI-generated content)
    dynamic chartContent;
    bool isAIGenerated = false;
    
    try {
      chartContent = jsonDecode(chart.chartData) as Map<String, dynamic>;
    } catch (e) {
      // It's AI-generated text content
      chartContent = chart.chartData;
      isAIGenerated = true;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getChartTitle(chart.chartType)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAIGenerated)
                // Display AI-generated content as formatted text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                  ),
                  child: SelectableText(
                    chartContent,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                )
              else
                _buildChartContent(chart.chartType, chartContent),
              if (chart.notes != null && chart.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Doctor\'s Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(chart.notes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getChartTitle(String chartType) {
    switch (chartType) {
      case AppConstants.chartTypeFood:
        return 'Weekly Food Chart';
      case AppConstants.chartTypeMedicine:
        return 'Monthly Medicine Chart';
      case AppConstants.chartTypeActivity:
        return 'Child Activity Chart';
      default:
        return 'Health Chart';
    }
  }

  IconData _getChartIcon(String chartType) {
    switch (chartType) {
      case AppConstants.chartTypeFood:
        return Icons.restaurant;
      case AppConstants.chartTypeMedicine:
        return Icons.medication;
      case AppConstants.chartTypeActivity:
        return Icons.directions_run;
      default:
        return Icons.analytics;
    }
  }

  Color _getChartColor(String chartType) {
    switch (chartType) {
      case AppConstants.chartTypeFood:
        return AppColors.success;
      case AppConstants.chartTypeMedicine:
        return AppColors.error;
      case AppConstants.chartTypeActivity:
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildChartContent(String chartType, Map<String, dynamic> chartData) {
    if (chartType == AppConstants.chartTypeFood) {
      final items = chartData['items'] as List;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['day'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMealRow('Breakfast', item['breakfast']),
                  _buildMealRow('Lunch', item['lunch']),
                  _buildMealRow('Dinner', item['dinner']),
                ],
              ),
            ),
          );
        }).toList(),
      );
    } else if (chartType == AppConstants.chartTypeMedicine) {
      final medicines = chartData['medicines'] as List;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...medicines.map((med) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.medication, color: AppColors.error),
                title: Text(
                  med['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dosage: ${med['dosage']}'),
                    Text('Frequency: ${med['frequency']}'),
                    Text('Time: ${med['time']}'),
                  ],
                ),
              ),
            );
          }).toList(),
          if (chartData['notes'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(child: Text(chartData['notes'])),
                ],
              ),
            ),
          ],
        ],
      );
    } else if (chartType == AppConstants.chartTypeActivity) {
      final activities = chartData['activities'] as List;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: activities.map((activity) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.info.withOpacity(0.2),
                child: const Icon(Icons.schedule, color: AppColors.info, size: 20),
              ),
              title: Text(activity['time']),
              subtitle: Text(activity['activity']),
            ),
          );
        }).toList(),
      );
    }
    return const Text('Chart data not available');
  }

  Widget _buildMealRow(String meal, String food) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$meal:',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              food,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_charts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No health charts yet',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your doctor will generate charts for you',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCharts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _charts.length,
        itemBuilder: (context, index) {
          final chart = _charts[index];
          final color = _getChartColor(chart.chartType);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => _showChartDetails(chart),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getChartIcon(chart.chartType),
                        color: color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getChartTitle(chart.chartType),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Generated on ${chart.generatedAt.day}/${chart.generatedAt.month}/${chart.generatedAt.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
