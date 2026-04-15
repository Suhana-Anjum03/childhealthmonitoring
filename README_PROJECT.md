# Child Health Monitoring System

A comprehensive Flutter mobile application for automated child health monitoring, connecting parents with pediatric doctors for efficient healthcare management.

## 📱 Project Overview

The Child Health Monitoring System bridges the gap between parents and pediatric doctors through:
- **Role-based access** for Admin, Doctor, and Parent users
- **Local database storage** using SQLite (no cloud dependencies)
- **ML-based health chart generation** for food, medicine, and activity schedules
- **Real-time chat** between doctors and parents
- **Appointment management** system
- **Medical chatbot** for first-aid guidance
- **OpenStreetMap integration** for location services

## 🎯 Key Features

### Admin Module
- Review and verify doctor registrations
- Approve/reject doctor accounts within 24 hours
- View all doctor profiles and license details
- Manage system users

### Doctor Module
- **Registration**: Submit license details, hospital info, and specialization
- **Parent Requests**: Accept/reject parent consultation requests
- **ML Chart Generation**: Create personalized health charts:
  - Weekly Food Chart
  - Monthly Medicine Chart
  - Child Activity Chart
- **Appointment Management**: Schedule and manage hospital appointments
- **Chat**: Direct communication with accepted parents
- **Patient Management**: View and manage patient profiles

### Parent Module
- **Registration**: Add parent and child information
- **Doctor Search**: Browse and send requests to approved doctors
- **Medical Chatbot**: Get first-aid guidance and home remedies
- **Chat**: Communicate with accepted doctors
- **Appointments**: Request and track hospital appointments
- **Health Charts**: View generated food, medicine, and activity charts
- **Profile**: Manage parent and child information

## 🏗️ Architecture

```
lib/
├── main.dart                 # App entry point with splash screen
├── models/                   # Data models
│   ├── user_model.dart
│   ├── doctor_model.dart
│   ├── parent_model.dart
│   ├── child_model.dart
│   ├── appointment_model.dart
│   ├── doctor_parent_request_model.dart
│   ├── health_chart_model.dart
│   └── chat_message_model.dart
├── services/                 # Business logic
│   ├── database_service.dart # SQLite database operations
│   └── auth_service.dart     # Authentication & session management
├── screens/                  # UI screens
│   ├── auth/                 # Login, registration, forgot password
│   ├── admin/                # Admin dashboard
│   ├── doctor/               # Doctor dashboard & features
│   └── parent/               # Parent dashboard & features
├── widgets/                  # Reusable UI components
│   ├── custom_button.dart
│   └── custom_text_field.dart
└── utils/                    # Constants & utilities
    ├── constants.dart
    ├── app_colors.dart
    └── validators.dart
```

## 📦 Dependencies

```yaml
dependencies:
  # Local Database
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  
  # State Management
  provider: ^6.1.1
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # Maps
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
  
  # HTTP & API
  http: ^1.1.0
  
  # Image Handling
  image_picker: ^1.0.4
  
  # Utilities
  intl: ^0.18.1
  crypto: ^3.0.3
  
  # UI Components
  flutter_svg: ^2.0.9
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**
   ```bash
   cd d:/projects/childhealthmonitoring
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🔐 Default Admin Credentials

For initial setup, use these credentials to access the admin panel:

- **Email**: `admin@childhealth.com`
- **Password**: `admin123`

⚠️ **Important**: Change these credentials after first login in a production environment.

## 📊 Database Schema

The app uses SQLite with the following tables:

- **users**: User authentication (email, password, role)
- **doctors**: Doctor profiles and license information
- **parents**: Parent profiles
- **children**: Child health information
- **appointments**: Appointment scheduling
- **doctor_parent_requests**: Connection requests between doctors and parents
- **health_charts**: ML-generated health charts
- **chat_messages**: Chat history

## 🎨 User Flows

### Doctor Registration Flow
1. Register with license details
2. Wait for admin approval (24 hours)
3. Login after approval
4. Accept parent requests
5. Generate health charts
6. Manage appointments

### Parent Registration Flow
1. Register with parent and child details
2. Login immediately
3. Search and request doctors
4. Chat with accepted doctors
5. Book appointments
6. View health charts

### Admin Flow
1. Login with admin credentials
2. Review pending doctor requests
3. Approve/reject based on license verification
4. Monitor system activity

## 🤖 Chatbot Features

The medical chatbot provides guidance for:
- Fever management
- Cough & cold remedies
- Vomiting & nausea
- Diarrhea treatment
- Skin rashes
- Minor cuts & wounds
- Burns (first aid)
- Stomach pain
- Sleep problems
- Appetite issues

⚠️ **Disclaimer**: The chatbot provides basic guidance only. For serious medical issues, users must consult their doctor.

## 🗺️ OpenStreetMap Integration

The app uses OpenStreetMap (via flutter_map) instead of Google Maps to:
- Reduce API costs
- Show doctor locations
- Display hospital addresses
- Provide location-based doctor search

## 🔒 Security Features

- **Password Hashing**: SHA-256 encryption for all passwords
- **Session Management**: Secure local session storage
- **Role-based Access**: Strict permission controls
- **Data Validation**: Input validation on all forms
- **Local Storage**: All data stored locally on device

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web (with limitations)
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🎯 Future Enhancements

- [ ] Push notifications for appointments
- [ ] Vaccination tracking
- [ ] Growth chart visualization
- [ ] Medicine reminder system
- [ ] Video consultation feature
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Export health reports as PDF
- [ ] Integration with wearable devices
- [ ] Cloud backup option

## 🐛 Known Issues

- ML chart generation is currently simulated (needs real ML API integration)
- OpenStreetMap requires internet connection
- Image picker may need additional permissions on iOS

## 📝 License

This project is created for educational purposes.

## 👥 User Roles Summary

| Role | Key Features |
|------|-------------|
| **Admin** | Doctor verification, user management |
| **Doctor** | Patient management, chart generation, appointments |
| **Parent** | Doctor search, chatbot, appointments, health charts |

## 🔧 Troubleshooting

### Database Issues
```bash
flutter clean
flutter pub get
flutter run
```

### Build Errors
- Ensure Flutter SDK is up to date
- Check that all dependencies are compatible
- Clear build cache if needed

### Permission Issues (Android)
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

## 📞 Support

For issues or questions:
1. Check the documentation
2. Review existing issues
3. Create a new issue with detailed description

---

**Built with ❤️ using Flutter**
