import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/parent_model.dart';
import '../../models/child_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({Key? key}) : super(key: key);

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  final _authService = AuthService();
  final _dbService = DatabaseService.instance;
  ParentModel? _parent;
  ChildModel? _child;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final parent = await _dbService.getParentByUserId(userId);
        if (parent != null) {
          final child = await _dbService.getChildByParentId(parent.id!);
          setState(() {
            _parent = parent;
            _child = child;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_parent == null) {
      return const Center(
        child: Text('Profile not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.parentColor,
            child: Text(
              _parent!.name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 48,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _parent!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Parent',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _buildParentInfoCard(),
          if (_child != null) ...[
            const SizedBox(height: 16),
            _buildChildInfoCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildParentInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parent Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email, 'Email', _parent!.email),
            _buildInfoRow(Icons.phone, 'Phone', _parent!.phoneNumber),
            _buildInfoRow(Icons.cake, 'Age', '${_parent!.age} years'),
            _buildInfoRow(Icons.person, 'Gender', _parent!.gender),
          ],
        ),
      ),
    );
  }

  Widget _buildChildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.child_care, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Child Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Name', _child!.name),
            _buildInfoRow(Icons.cake, 'Age', '${_child!.age} years'),
            _buildInfoRow(
              Icons.calendar_today,
              'Date of Birth',
              DateFormat('dd/MM/yyyy').format(_child!.dateOfBirth),
            ),
            _buildInfoRow(Icons.monitor_weight, 'Weight', '${_child!.weight} kg'),
            _buildInfoRow(Icons.height, 'Height', '${_child!.height} cm'),
            _buildInfoRow(Icons.location_on, 'Place of Birth', _child!.placeOfBirth),
            _buildInfoRow(Icons.person_outline, 'Gender', _child!.gender),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
