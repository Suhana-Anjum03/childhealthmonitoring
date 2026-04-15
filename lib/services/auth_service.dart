import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class AuthService {
  final DatabaseService _db = DatabaseService.instance;

  // Login
  Future<UserModel?> login(String email, String password) async {
    final user = await _db.authenticateUser(email, password);
    if (user != null) {
      await _saveSession(user);
    }
    return user;
  }

  // Register User
  Future<int> registerUser(UserModel user) async {
    return await _db.createUser(user);
  }

  // Save session
  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setInt(AppConstants.keyUserId, user.id!);
    await prefs.setString(AppConstants.keyUserRole, user.role);
    await prefs.setString(AppConstants.keyUserEmail, user.email);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  // Get current user ID
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.keyUserId);
  }

  // Get current user role
  Future<String?> getCurrentUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserRole);
  }

  // Get current user email
  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserEmail);
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;
    return await _db.getUserById(userId);
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Update password (for forgot password functionality)
  Future<bool> updatePassword(String email, String newPassword) async {
    final user = await _db.getUserByEmail(email);
    if (user == null) return false;
    
    // In a real app, you'd verify email through OTP or security questions
    // For now, we'll just update the password
    final updatedUser = UserModel(
      id: user.id,
      email: user.email,
      password: newPassword,
      role: user.role,
      createdAt: user.createdAt,
    );
    
    await _db.createUser(updatedUser);
    return true;
  }
}
