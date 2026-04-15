class AppConstants {
  // App Info
  static const String appName = 'Child Health Monitor';
  static const String appVersion = '1.0.0';
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleDoctor = 'doctor';
  static const String roleParent = 'parent';
  
  // Shared Preferences Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserEmail = 'user_email';
  
  // Doctor Approval Status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  
  // Parent Request Status
  static const String requestPending = 'pending';
  static const String requestAccepted = 'accepted';
  static const String requestRejected = 'rejected';
  
  // Chart Types
  static const String chartTypeFood = 'food';
  static const String chartTypeMedicine = 'medicine';
  static const String chartTypeActivity = 'activity';
  
  // Appointment Status
  static const String appointmentPending = 'pending';
  static const String appointmentConfirmed = 'confirmed';
  static const String appointmentCompleted = 'completed';
  static const String appointmentCancelled = 'cancelled';
  
  // Default Admin Credentials (for initial setup)
  static const String defaultAdminEmail = 'admin@childhealth.com';
  static const String defaultAdminPassword = 'admin123';
  
  // Gemini API Configuration
  static const String geminiApiKey = 'AIzaSyDfIzkqoglnyVvhd-ricxCSgPS0uHG20Jw';
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';
}
