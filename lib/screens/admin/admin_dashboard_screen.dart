import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _authService = AuthService();
  final _dbService = DatabaseService.instance;
  List<DoctorModel> _pendingDoctors = [];
  List<DoctorModel> _approvedDoctors = [];
  List<DoctorModel> _rejectedDoctors = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      final allDoctors = await _dbService.getAllDoctors();
      setState(() {
        _pendingDoctors = allDoctors
            .where((d) => d.approvalStatus == AppConstants.statusPending)
            .toList();
        _approvedDoctors = allDoctors
            .where((d) => d.approvalStatus == AppConstants.statusApproved)
            .toList();
        _rejectedDoctors = allDoctors
            .where((d) => d.approvalStatus == AppConstants.statusRejected)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading doctors: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveDoctor(DoctorModel doctor) async {
    try {
      final updatedDoctor = doctor.copyWith(
        approvalStatus: AppConstants.statusApproved,
        approvedAt: DateTime.now(),
      );
      await _dbService.updateDoctor(updatedDoctor);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor approved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadDoctors();
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

  Future<void> _rejectDoctor(DoctorModel doctor) async {
    final reasonController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Doctor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final updatedDoctor = doctor.copyWith(
          approvalStatus: AppConstants.statusRejected,
          rejectionReason: reasonController.text.trim(),
        );
        await _dbService.updateDoctor(updatedDoctor);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doctor rejected'),
              backgroundColor: AppColors.warning,
            ),
          );
          _loadDoctors();
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
  }

  void _showDoctorDetails(DoctorModel doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doctor.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', doctor.email),
              _buildDetailRow('Phone', doctor.phoneNumber),
              _buildDetailRow('License ID', doctor.licenseId),
              _buildDetailRow('Hospital', doctor.hospitalName),
              _buildDetailRow('Location', doctor.workingLocation),
              _buildDetailRow('Age', doctor.age.toString()),
              _buildDetailRow('Specialization', doctor.specialization),
              _buildDetailRow('Status', doctor.approvalStatus),
              if (doctor.rejectionReason != null)
                _buildDetailRow('Rejection Reason', doctor.rejectionReason!),
              _buildDetailRow(
                'Applied On',
                DateFormat('dd/MM/yyyy').format(doctor.createdAt),
              ),
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
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.doctorColor,
          child: Text(
            doctor.name[0].toUpperCase(),
            style: const TextStyle(color: AppColors.white),
          ),
        ),
        title: Text(
          doctor.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctor.specialization),
            Text(doctor.hospitalName, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: _selectedIndex == 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: AppColors.success),
                    onPressed: () => _approveDoctor(doctor),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: AppColors.error),
                    onPressed: () => _rejectDoctor(doctor),
                  ),
                ],
              )
            : null,
        onTap: () => _showDoctorDetails(doctor),
      ),
    );
  }

  Widget _buildDoctorList(List<DoctorModel> doctors, String emptyMessage) {
    if (doctors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: doctors.length,
      itemBuilder: (context, index) => _buildDoctorCard(doctors[index]),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.adminColor,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDoctors,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: AppColors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          'Pending',
                          _pendingDoctors.length,
                          0,
                          AppColors.warning,
                        ),
                      ),
                      Expanded(
                        child: _buildTabButton(
                          'Approved',
                          _approvedDoctors.length,
                          1,
                          AppColors.success,
                        ),
                      ),
                      Expanded(
                        child: _buildTabButton(
                          'Rejected',
                          _rejectedDoctors.length,
                          2,
                          AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      _buildDoctorList(
                        _pendingDoctors,
                        'No pending doctor requests',
                      ),
                      _buildDoctorList(
                        _approvedDoctors,
                        'No approved doctors yet',
                      ),
                      _buildDoctorList(
                        _rejectedDoctors,
                        'No rejected doctors',
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabButton(String label, int count, int index, Color color) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? color : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
