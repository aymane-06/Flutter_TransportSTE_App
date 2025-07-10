import 'package:myapp/features/home/models/expenc_model.dart';
import 'package:myapp/features/home/models/trip_model.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final List<Trip> trips;
  final List<ExpenseModel> expenses;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.role = 'Driver',
    this.trips = const [],
    this.expenses = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle image_1920 field - it can be false, null, or a base64 string
      String? avatarImage;
      final image1920 = json['image_1920'];
      if (image1920 != null &&
          image1920 != false &&
          image1920 is String &&
          image1920.isNotEmpty) {
        avatarImage = image1920;
      }

      // Handle groups_id to determine role
      String userRole = 'Driver'; // Default role
      final groupsId = json['groups_id'];
      if (groupsId is List && groupsId.isNotEmpty) {
        // Map specific group IDs to roles based on your Odoo setup
        if (groupsId.contains(47)) {
          userRole = 'Manager';
        } else if (groupsId.contains(60)) {
          userRole = 'Driver';
        } else if (groupsId.contains(15)) {
          userRole = 'User';
        } else {
          userRole = 'User';
        }
      }

      // Parse each field safely
      final parsedId = _parseInt(json['id']) ?? 0;

      final parsedName = _parseString(json['name']) ?? 'Unknown User';

      final parsedEmail =
          _parseString(json['email']) ?? _parseString(json['login']) ?? '';

      return UserModel(
        id: parsedId,
        name: parsedName,
        email: parsedEmail,
        avatar: avatarImage,
        role: userRole,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role,
    };
  }

  // Helper methods for safe type conversion
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value == false) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is bool) return null; // Explicitly handle boolean case
    return value.toString();
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }
}
