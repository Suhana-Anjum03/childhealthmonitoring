import 'package:flutter/material.dart';
import '../../models/doctor_parent_request_model.dart';
import '../../models/parent_model.dart';
import '../../models/child_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class DoctorRequestsScreen extends StatefulWidget {
  const DoctorRequestsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorRequestsScreen> createState() => _DoctorRequestsScreenState();
}

class _DoctorRequestsScreenState extends State<DoctorRequestsScreen> {
  final _authService = AuthService();
  final _dbService = DatabaseService.instance;
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final doctor = await _dbService.getDoctorByUserId(userId);
        if (doctor != null) {
          final requests = await _dbService.getPendingRequestsByDoctorId(doctor.id!);
          
          final requestsWithDetails = <Map<String, dynamic>>[];
          for (var request in requests) {
            final parent = await _dbService.getParentById(request.parentId);
            final child = await _dbService.getChildByParentId(request.parentId);
            if (parent != null) {
              requestsWithDetails.add({
                'request': request,
                'parent': parent,
                'child': child,
              });
            }
          }
          
          setState(() => _requests = requestsWithDetails);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading requests: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptRequest(DoctorParentRequestModel request) async {
    try {
      final updatedRequest = request.copyWith(
        status: AppConstants.requestAccepted,
        respondedAt: DateTime.now(),
      );
      await _dbService.updateDoctorParentRequest(updatedRequest);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request accepted'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(DoctorParentRequestModel request) async {
    try {
      final updatedRequest = request.copyWith(
        status: AppConstants.requestRejected,
        respondedAt: DateTime.now(),
      );
      await _dbService.updateDoctorParentRequest(updatedRequest);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request rejected'),
            backgroundColor: AppColors.warning,
          ),
        );
        _loadRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showRequestDetails(Map<String, dynamic> data) {
    final parent = data['parent'] as ParentModel;
    final child = data['child'] as ChildModel?;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Parent Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Parent Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Name', parent.name),
              _buildDetailRow('Age', parent.age.toString()),
              _buildDetailRow('Phone', parent.phoneNumber),
              _buildDetailRow('Email', parent.email),
              _buildDetailRow('Gender', parent.gender),
              if (child != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Child Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Name', child.name),
                _buildDetailRow('Age', '${child.age} years'),
                _buildDetailRow('Weight', '${child.weight} kg'),
                _buildDetailRow('Height', '${child.height} cm'),
                _buildDetailRow('Gender', child.gender),
                _buildDetailRow('Place of Birth', child.placeOfBirth),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No pending requests',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final data = _requests[index];
          final request = data['request'] as DoctorParentRequestModel;
          final parent = data['parent'] as ParentModel;
          final child = data['child'] as ChildModel?;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.parentColor,
                        child: Text(
                          parent.name[0].toUpperCase(),
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              parent.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              parent.email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (child != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.child_care, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Child: ${child.name}, ${child.age} years',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRequestDetails(data),
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('View Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.info,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptRequest(request),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _rejectRequest(request),
                        icon: const Icon(Icons.close, color: AppColors.error),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
