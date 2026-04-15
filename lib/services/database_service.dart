import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/doctor_model.dart';
import '../models/parent_model.dart';
import '../models/child_model.dart';
import '../models/appointment_model.dart';
import '../models/doctor_parent_request_model.dart';
import '../models/health_chart_model.dart';
import '../models/chat_message_model.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('child_health_monitor.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Doctors table
    await db.execute('''
      CREATE TABLE doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        email TEXT NOT NULL,
        license_id TEXT NOT NULL,
        working_location TEXT NOT NULL,
        hospital_name TEXT NOT NULL,
        age INTEGER NOT NULL,
        specialization TEXT NOT NULL,
        profile_photo TEXT,
        approval_status TEXT NOT NULL DEFAULT 'pending',
        rejection_reason TEXT,
        created_at TEXT NOT NULL,
        approved_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Parents table
    await db.execute('''
      CREATE TABLE parents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        phone_number TEXT NOT NULL,
        email TEXT NOT NULL,
        gender TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Children table
    await db.execute('''
      CREATE TABLE children (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parent_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        date_of_birth TEXT NOT NULL,
        place_of_birth TEXT NOT NULL,
        gender TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES parents (id) ON DELETE CASCADE
      )
    ''');

    // Appointments table
    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parent_id INTEGER NOT NULL,
        doctor_id INTEGER NOT NULL,
        appointment_date TEXT NOT NULL,
        appointment_time TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (parent_id) REFERENCES parents (id) ON DELETE CASCADE,
        FOREIGN KEY (doctor_id) REFERENCES doctors (id) ON DELETE CASCADE
      )
    ''');

    // Doctor-Parent Requests table
    await db.execute('''
      CREATE TABLE doctor_parent_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parent_id INTEGER NOT NULL,
        doctor_id INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL,
        responded_at TEXT,
        FOREIGN KEY (parent_id) REFERENCES parents (id) ON DELETE CASCADE,
        FOREIGN KEY (doctor_id) REFERENCES doctors (id) ON DELETE CASCADE
      )
    ''');

    // Health Charts table
    await db.execute('''
      CREATE TABLE health_charts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parent_id INTEGER NOT NULL,
        doctor_id INTEGER NOT NULL,
        child_id INTEGER NOT NULL,
        chart_type TEXT NOT NULL,
        chart_data TEXT NOT NULL,
        generated_at TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (parent_id) REFERENCES parents (id) ON DELETE CASCADE,
        FOREIGN KEY (doctor_id) REFERENCES doctors (id) ON DELETE CASCADE,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    // Chat Messages table
    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender_id INTEGER NOT NULL,
        receiver_id INTEGER NOT NULL,
        sender_role TEXT NOT NULL,
        message TEXT NOT NULL,
        sent_at TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create default admin user
    await _createDefaultAdmin(db);
  }

  Future<void> _createDefaultAdmin(Database db) async {
    final hashedPassword = _hashPassword(AppConstants.defaultAdminPassword);
    await db.insert('users', {
      'email': AppConstants.defaultAdminEmail,
      'password': hashedPassword,
      'role': AppConstants.roleAdmin,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // User operations
  Future<int> createUser(UserModel user) async {
    final db = await database;
    final hashedUser = UserModel(
      email: user.email,
      password: _hashPassword(user.password),
      role: user.role,
      createdAt: user.createdAt,
    );
    return await db.insert('users', hashedUser.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> authenticateUser(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user == null) return null;
    
    final hashedPassword = _hashPassword(password);
    if (user.password == hashedPassword) {
      return user;
    }
    return null;
  }

  // Doctor operations
  Future<int> createDoctor(DoctorModel doctor) async {
    final db = await database;
    return await db.insert('doctors', doctor.toMap());
  }

  Future<DoctorModel?> getDoctorByUserId(int userId) async {
    final db = await database;
    final maps = await db.query(
      'doctors',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (maps.isEmpty) return null;
    return DoctorModel.fromMap(maps.first);
  }

  Future<DoctorModel?> getDoctorById(int id) async {
    final db = await database;
    final maps = await db.query(
      'doctors',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DoctorModel.fromMap(maps.first);
  }

  Future<List<DoctorModel>> getAllDoctors() async {
    final db = await database;
    final maps = await db.query('doctors');
    return maps.map((map) => DoctorModel.fromMap(map)).toList();
  }

  Future<List<DoctorModel>> getPendingDoctors() async {
    final db = await database;
    final maps = await db.query(
      'doctors',
      where: 'approval_status = ?',
      whereArgs: [AppConstants.statusPending],
    );
    return maps.map((map) => DoctorModel.fromMap(map)).toList();
  }

  Future<List<DoctorModel>> getApprovedDoctors() async {
    final db = await database;
    final maps = await db.query(
      'doctors',
      where: 'approval_status = ?',
      whereArgs: [AppConstants.statusApproved],
    );
    return maps.map((map) => DoctorModel.fromMap(map)).toList();
  }

  Future<int> updateDoctor(DoctorModel doctor) async {
    final db = await database;
    return await db.update(
      'doctors',
      doctor.toMap(),
      where: 'id = ?',
      whereArgs: [doctor.id],
    );
  }

  // Parent operations
  Future<int> createParent(ParentModel parent) async {
    final db = await database;
    return await db.insert('parents', parent.toMap());
  }

  Future<ParentModel?> getParentByUserId(int userId) async {
    final db = await database;
    final maps = await db.query(
      'parents',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (maps.isEmpty) return null;
    return ParentModel.fromMap(maps.first);
  }

  Future<ParentModel?> getParentById(int id) async {
    final db = await database;
    final maps = await db.query(
      'parents',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ParentModel.fromMap(maps.first);
  }

  // Child operations
  Future<int> createChild(ChildModel child) async {
    final db = await database;
    return await db.insert('children', child.toMap());
  }

  Future<ChildModel?> getChildByParentId(int parentId) async {
    final db = await database;
    final maps = await db.query(
      'children',
      where: 'parent_id = ?',
      whereArgs: [parentId],
    );
    if (maps.isEmpty) return null;
    return ChildModel.fromMap(maps.first);
  }

  Future<ChildModel?> getChildById(int id) async {
    final db = await database;
    final maps = await db.query(
      'children',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ChildModel.fromMap(maps.first);
  }

  // Appointment operations
  Future<int> createAppointment(AppointmentModel appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment.toMap());
  }

  Future<List<AppointmentModel>> getAppointmentsByDoctorId(int doctorId) async {
    final db = await database;
    final maps = await db.query(
      'appointments',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'appointment_date DESC',
    );
    return maps.map((map) => AppointmentModel.fromMap(map)).toList();
  }

  Future<List<AppointmentModel>> getAppointmentsByParentId(int parentId) async {
    final db = await database;
    final maps = await db.query(
      'appointments',
      where: 'parent_id = ?',
      whereArgs: [parentId],
      orderBy: 'appointment_date DESC',
    );
    return maps.map((map) => AppointmentModel.fromMap(map)).toList();
  }

  Future<int> updateAppointment(AppointmentModel appointment) async {
    final db = await database;
    return await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  // Doctor-Parent Request operations
  Future<int> createDoctorParentRequest(DoctorParentRequestModel request) async {
    final db = await database;
    return await db.insert('doctor_parent_requests', request.toMap());
  }

  Future<List<DoctorParentRequestModel>> getPendingRequestsByDoctorId(int doctorId) async {
    final db = await database;
    final maps = await db.query(
      'doctor_parent_requests',
      where: 'doctor_id = ? AND status = ?',
      whereArgs: [doctorId, AppConstants.requestPending],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => DoctorParentRequestModel.fromMap(map)).toList();
  }

  Future<DoctorParentRequestModel?> getRequestByParentAndDoctor(int parentId, int doctorId) async {
    final db = await database;
    final maps = await db.query(
      'doctor_parent_requests',
      where: 'parent_id = ? AND doctor_id = ?',
      whereArgs: [parentId, doctorId],
    );
    if (maps.isEmpty) return null;
    return DoctorParentRequestModel.fromMap(maps.first);
  }

  Future<int> updateDoctorParentRequest(DoctorParentRequestModel request) async {
    final db = await database;
    return await db.update(
      'doctor_parent_requests',
      request.toMap(),
      where: 'id = ?',
      whereArgs: [request.id],
    );
  }

  Future<List<DoctorModel>> getAcceptedDoctorsByParentId(int parentId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT d.* FROM doctors d
      INNER JOIN doctor_parent_requests dpr ON d.id = dpr.doctor_id
      WHERE dpr.parent_id = ? AND dpr.status = ?
    ''', [parentId, AppConstants.requestAccepted]);
    return maps.map((map) => DoctorModel.fromMap(map)).toList();
  }

  Future<List<ParentModel>> getAcceptedParentsByDoctorId(int doctorId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT p.* FROM parents p
      INNER JOIN doctor_parent_requests dpr ON p.id = dpr.parent_id
      WHERE dpr.doctor_id = ? AND dpr.status = ?
    ''', [doctorId, AppConstants.requestAccepted]);
    return maps.map((map) => ParentModel.fromMap(map)).toList();
  }

  // Health Chart operations
  Future<int> createHealthChart(HealthChartModel chart) async {
    final db = await database;
    return await db.insert('health_charts', chart.toMap());
  }

  Future<List<HealthChartModel>> getChartsByParentId(int parentId) async {
    final db = await database;
    final maps = await db.query(
      'health_charts',
      where: 'parent_id = ?',
      whereArgs: [parentId],
      orderBy: 'generated_at DESC',
    );
    return maps.map((map) => HealthChartModel.fromMap(map)).toList();
  }

  Future<List<HealthChartModel>> getChartsByDoctorId(int doctorId) async {
    final db = await database;
    final maps = await db.query(
      'health_charts',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'generated_at DESC',
    );
    return maps.map((map) => HealthChartModel.fromMap(map)).toList();
  }

  // Chat Message operations
  Future<int> createChatMessage(ChatMessageModel message) async {
    final db = await database;
    return await db.insert('chat_messages', message.toMap());
  }

  Future<List<ChatMessageModel>> getChatMessages(int userId1, int userId2) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT * FROM chat_messages
      WHERE (sender_id = ? AND receiver_id = ?)
         OR (sender_id = ? AND receiver_id = ?)
      ORDER BY sent_at ASC
    ''', [userId1, userId2, userId2, userId1]);
    return maps.map((map) => ChatMessageModel.fromMap(map)).toList();
  }

  Future<int> markMessageAsRead(int messageId) async {
    final db = await database;
    return await db.update(
      'chat_messages',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> markAllMessagesAsRead(int receiverId, int senderId) async {
    final db = await database;
    await db.update(
      'chat_messages',
      {'is_read': 1},
      where: 'receiver_id = ? AND sender_id = ? AND is_read = 0',
      whereArgs: [receiverId, senderId],
    );
  }

  Future<int> getUnreadMessageCount(int receiverId, int senderId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM chat_messages
      WHERE receiver_id = ? AND sender_id = ? AND is_read = 0
    ''', [receiverId, senderId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalUnreadMessageCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM chat_messages
      WHERE receiver_id = ? AND is_read = 0
    ''', [userId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
