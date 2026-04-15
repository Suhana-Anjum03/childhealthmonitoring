import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../models/doctor_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ParentAppointmentsScreen extends StatefulWidget {
  const ParentAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<ParentAppointmentsScreen> createState() => _ParentAppointmentsScreenState();
}

class _ParentAppointmentsScreenState extends State<ParentAppointmentsScreen> {
  final _authService = AuthService();
  final _dbService = DatabaseService.instance;
  List<Map<String, dynamic>> _appointments = [];
  List<DoctorModel> _myDoctors = [];
  bool _isLoading = true;
  int? _parentId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final parent = await _dbService.getParentByUserId(userId);
        if (parent != null) {
          setState(() => _parentId = parent.id);
          
          final appointments = await _dbService.getAppointmentsByParentId(parent.id!);
          final doctors = await _dbService.getAcceptedDoctorsByParentId(parent.id!);
          
          final appointmentsWithDoctors = <Map<String, dynamic>>[];
          for (var appointment in appointments) {
            final doctor = await _dbService.getDoctorById(appointment.doctorId);
            if (doctor != null) {
              appointmentsWithDoctors.add({
                'appointment': appointment,
                'doctor': doctor,
              });
            }
          }
          
          setState(() {
            _appointments = appointmentsWithDoctors;
            _myDoctors = doctors;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showBookAppointmentDialog() {
    if (_myDoctors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect with a doctor first'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    DoctorModel? selectedDoctor = _myDoctors.first;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Book Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Doctor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<DoctorModel>(
                  value: selectedDoctor,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _myDoctors.map((doctor) {
                    return DropdownMenuItem(
                      value: doctor,
                      child: Text('Dr. ${doctor.name}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedDoctor = value);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.greyLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate == null
                              ? 'Select date'
                              : DateFormat('dd/MM/yyyy').format(selectedDate!),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Time',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setDialogState(() => selectedTime = time);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.greyLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          selectedTime == null
                              ? 'Select time'
                              : selectedTime!.format(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: notesController,
                  label: 'Notes (Optional)',
                  hint: 'Add any notes...',
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedDoctor == null || selectedDate == null || selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                try {
                  final appointment = AppointmentModel(
                    parentId: _parentId!,
                    doctorId: selectedDoctor!.id!,
                    appointmentDate: selectedDate!,
                    appointmentTime: selectedTime!.format(context),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );

                  await _dbService.createAppointment(appointment);
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment request sent'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Book'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.appointmentPending:
        return AppColors.warning;
      case AppConstants.appointmentConfirmed:
        return AppColors.info;
      case AppConstants.appointmentCompleted:
        return AppColors.success;
      case AppConstants.appointmentCancelled:
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: _appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 80,
                    color: AppColors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No appointments',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Book an appointment with your doctor',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _appointments.length,
                itemBuilder: (context, index) {
                  final data = _appointments[index];
                  final appointment = data['appointment'] as AppointmentModel;
                  final doctor = data['doctor'] as DoctorModel;

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
                                backgroundColor: AppColors.doctorColor,
                                child: Text(
                                  doctor.name[0].toUpperCase(),
                                  style: const TextStyle(color: AppColors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dr. ${doctor.name}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      doctor.specialization,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(appointment.status)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  appointment.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(appointment.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 16, color: AppColors.grey),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('EEEE, dd MMM yyyy')
                                    .format(appointment.appointmentDate),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 16, color: AppColors.grey),
                              const SizedBox(width: 8),
                              Text(
                                appointment.appointmentTime,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          if (appointment.notes != null &&
                              appointment.notes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.note,
                                    size: 16, color: AppColors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    appointment.notes!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showBookAppointmentDialog,
        backgroundColor: AppColors.parentColor,
        icon: const Icon(Icons.add),
        label: const Text('Book Appointment'),
      ),
    );
  }
}
