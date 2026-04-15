import 'package:flutter/material.dart';
import '../../models/child_model.dart';
import '../../models/parent_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'package:intl/intl.dart';

class ParentRegisterScreen extends StatefulWidget {
  const ParentRegisterScreen({Key? key}) : super(key: key);

  @override
  State<ParentRegisterScreen> createState() => _ParentRegisterScreenState();
}

class _ParentRegisterScreenState extends State<ParentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Parent fields
  final _parentNameController = TextEditingController();
  final _parentAgeController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _parentGender = 'Male';
  
  // Child fields
  final _childNameController = TextEditingController();
  final _childAgeController = TextEditingController();
  final _childWeightController = TextEditingController();
  final _childHeightController = TextEditingController();
  final _childPlaceController = TextEditingController();
  DateTime? _childDOB;
  String _childGender = 'Male';
  
  final _authService = AuthService();
  final _dbService = DatabaseService.instance;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _parentNameController.dispose();
    _parentAgeController.dispose();
    _parentPhoneController.dispose();
    _parentEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _childNameController.dispose();
    _childAgeController.dispose();
    _childWeightController.dispose();
    _childHeightController.dispose();
    _childPlaceController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _childDOB = picked);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_childDOB == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select child\'s date of birth'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if email already exists
      final existingUser = await _dbService.getUserByEmail(
        _parentEmailController.text.trim(),
      );
      
      if (existingUser != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email already registered'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Create user account
      final user = UserModel(
        email: _parentEmailController.text.trim(),
        password: _passwordController.text,
        role: AppConstants.roleParent,
      );
      
      final userId = await _authService.registerUser(user);

      // Create parent profile
      final parent = ParentModel(
        userId: userId,
        name: _parentNameController.text.trim(),
        age: int.parse(_parentAgeController.text),
        phoneNumber: _parentPhoneController.text.trim(),
        email: _parentEmailController.text.trim(),
        gender: _parentGender,
      );

      final parentId = await _dbService.createParent(parent);

      // Create child profile
      final child = ChildModel(
        parentId: parentId,
        name: _childNameController.text.trim(),
        age: int.parse(_childAgeController.text),
        weight: double.parse(_childWeightController.text),
        height: double.parse(_childHeightController.text),
        dateOfBirth: _childDOB!,
        placeOfBirth: _childPlaceController.text.trim(),
        gender: _childGender,
      );

      await _dbService.createChild(child);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! You can now login.'),
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
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Parent Registration'),
        backgroundColor: AppColors.parentColor,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Parent Information Section
                const Text(
                  'Parent Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _parentNameController,
                  label: 'Parent Name',
                  hint: 'Enter your name',
                  validator: Validators.validateName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _parentAgeController,
                  label: 'Parent Age',
                  hint: 'Enter your age',
                  keyboardType: TextInputType.number,
                  validator: Validators.validateAge,
                  prefixIcon: const Icon(Icons.cake_outlined),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _parentPhoneController,
                  label: 'Phone Number',
                  hint: 'Enter 10-digit phone number',
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _parentEmailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 16),
                // Parent Gender
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Parent Gender',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Male'),
                            value: 'Male',
                            groupValue: _parentGender,
                            onChanged: (value) {
                              setState(() => _parentGender = value!);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Female'),
                            value: 'Female',
                            groupValue: _parentGender,
                            onChanged: (value) {
                              setState(() => _parentGender = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter password (min 6 characters)',
                  obscureText: _obscurePassword,
                  validator: Validators.validatePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter password',
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(thickness: 2),
                const SizedBox(height: 16),
                // Child Information Section
                const Text(
                  'Child Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _childNameController,
                  label: 'Child Name',
                  hint: 'Enter child\'s name',
                  validator: Validators.validateName,
                  prefixIcon: const Icon(Icons.child_care),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _childAgeController,
                  label: 'Child Age',
                  hint: 'Enter child\'s age',
                  keyboardType: TextInputType.number,
                  validator: Validators.validateAge,
                  prefixIcon: const Icon(Icons.cake_outlined),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _childWeightController,
                  label: 'Child Weight (kg)',
                  hint: 'Enter weight in kg',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.validateWeight,
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _childHeightController,
                  label: 'Child Height (cm)',
                  hint: 'Enter height in cm',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.validateHeight,
                  prefixIcon: const Icon(Icons.height_outlined),
                ),
                const SizedBox(height: 16),
                // Date of Birth
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Child Date of Birth',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyLight),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: AppColors.grey),
                            const SizedBox(width: 12),
                            Text(
                              _childDOB == null
                                  ? 'Select date of birth'
                                  : DateFormat('dd/MM/yyyy').format(_childDOB!),
                              style: TextStyle(
                                color: _childDOB == null
                                    ? AppColors.textHint
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _childPlaceController,
                  label: 'Place of Birth',
                  hint: 'Enter place of birth',
                  validator: (v) => Validators.validateRequired(v, 'Place of Birth'),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                const SizedBox(height: 16),
                // Child Gender
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Child Gender',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Male'),
                            value: 'Male',
                            groupValue: _childGender,
                            onChanged: (value) {
                              setState(() => _childGender = value!);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Female'),
                            value: 'Female',
                            groupValue: _childGender,
                            onChanged: (value) {
                              setState(() => _childGender = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Register',
                  onPressed: _register,
                  isLoading: _isLoading,
                  backgroundColor: AppColors.parentColor,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
