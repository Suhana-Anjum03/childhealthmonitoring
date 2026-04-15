import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';
import '../../models/doctor_parent_request_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/location_helper.dart';
import '../doctor/chat_screen.dart';
import '../common/map_screen.dart';

class ParentDoctorsScreen extends StatefulWidget {
  const ParentDoctorsScreen({Key? key}) : super(key: key);

  @override
  State<ParentDoctorsScreen> createState() => _ParentDoctorsScreenState();
}

class _ParentDoctorsScreenState extends State<ParentDoctorsScreen> {
  final _authService = AuthService();
  final _dbService = DatabaseService.instance;
  List<DoctorModel> _allDoctors = [];
  List<DoctorModel> _myDoctors = [];
  bool _isLoading = true;
  int _selectedTab = 0;
  int? _parentId;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final parent = await _dbService.getParentByUserId(userId);
        if (parent != null) {
          setState(() => _parentId = parent.id);
          
          final approvedDoctors = await _dbService.getApprovedDoctors();
          final myDoctors = await _dbService.getAcceptedDoctorsByParentId(parent.id!);
          
          // Filter out doctors that are already in "My Doctors"
          final myDoctorIds = myDoctors.map((d) => d.id).toSet();
          final availableDoctors = approvedDoctors
              .where((doctor) => !myDoctorIds.contains(doctor.id))
              .toList();
          
          setState(() {
            _allDoctors = availableDoctors;
            _myDoctors = myDoctors;
          });
        }
      }
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

  Future<void> _sendRequest(DoctorModel doctor) async {
    if (_parentId == null) return;

    try {
      // Check if request already exists
      final existingRequest = await _dbService.getRequestByParentAndDoctor(
        _parentId!,
        doctor.id!,
      );

      if (existingRequest != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request already sent to this doctor'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      final request = DoctorParentRequestModel(
        parentId: _parentId!,
        doctorId: doctor.id!,
      );

      await _dbService.createDoctorParentRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request sent successfully'),
            backgroundColor: AppColors.success,
          ),
        );
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

  void _showDoctorDetails(DoctorModel doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dr. ${doctor.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Specialization', doctor.specialization),
              _buildDetailRow('Hospital', doctor.hospitalName),
              _buildDetailRow('Location', doctor.workingLocation),
              _buildDetailRow('Phone', doctor.phoneNumber),
              _buildDetailRow('Email', doctor.email),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDoctorOnMap(doctor);
                  },
                  icon: const Icon(Icons.map, size: 18),
                  label: const Text('View on Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: AppColors.white,
                  ),
                ),
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

  void _showDoctorOnMap(DoctorModel doctor) {
    final coordinates = LocationHelper.getCoordinatesFromLocation(doctor.workingLocation);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapScreen(
          locationName: '${doctor.hospitalName}, ${doctor.workingLocation}',
          title: 'Dr. ${doctor.name}',
          coordinates: coordinates,
        ),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _navigateToChat(DoctorModel doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          otherUserId: doctor.id!,
          otherUserName: 'Dr. ${doctor.name}',
          currentUserRole: 'parent',
        ),
      ),
    ).then((_) => setState(() {})); // Refresh to update badge
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          color: AppColors.white,
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton('All Doctors', 0),
              ),
              Expanded(
                child: _buildTabButton('My Doctors', 1),
              ),
            ],
          ),
        ),
        Expanded(
          child: _selectedTab == 0
              ? _buildAllDoctorsList()
              : _buildMyDoctorsList(),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.parentColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.parentColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildAllDoctorsList() {
    if (_allDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital_outlined,
              size: 80,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No doctors available',
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
      onRefresh: _loadDoctors,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allDoctors.length,
        itemBuilder: (context, index) {
          final doctor = _allDoctors[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.doctorColor,
                child: Text(
                  doctor.name[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
              title: Text(
                'Dr. ${doctor.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.specialization),
                  Text(
                    doctor.hospitalName,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.success),
                onPressed: () => _sendRequest(doctor),
              ),
              onTap: () => _showDoctorDetails(doctor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyDoctorsList() {
    if (_myDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No doctors yet',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Send requests to doctors to see them here',
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
      onRefresh: _loadDoctors,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myDoctors.length,
        itemBuilder: (context, index) {
          final doctor = _myDoctors[index];
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
                        radius: 30,
                        backgroundColor: AppColors.doctorColor,
                        child: Text(
                          doctor.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. ${doctor.name}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor.specialization,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              doctor.hospitalName,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDoctorDetails(doctor),
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('View Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.info,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FutureBuilder<int>(
                          future: _parentId != null 
                              ? _dbService.getUnreadMessageCount(_parentId!, doctor.id!)
                              : Future.value(0),
                          builder: (context, snapshot) {
                            final unreadCount = snapshot.data ?? 0;
                            return Stack(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _navigateToChat(doctor),
                                  icon: const Icon(Icons.chat, size: 18),
                                  label: const Text('Chat'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.parentColor,
                                    foregroundColor: AppColors.white,
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 20,
                                      ),
                                      child: Text(
                                        unreadCount > 9 ? '9+' : '$unreadCount',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
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
