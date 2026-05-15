import 'dart:convert';
import '../../../../core/constants/app_enums.dart';

class UserModel {
  final String userId;
  final String userName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final AuthProvider authProvider; 
  final UserRole role;        
  final UserStatus status;
  final bool? isLandlord;
  final List<String> fcmTokens;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.userId,
    required this.userName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.authProvider = AuthProvider.email,
    this.role = UserRole.tenant,
    this.status = UserStatus.active,
    this.isLandlord = false,
    this.fcmTokens = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'authProvider': authProvider.toJson(),
      'role': role.toJson(),
      'status': status.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isLandlord': isLandlord,
      'fcmTokens': fcmTokens,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: (map['userId'] ?? '') as String,
      userName: (map['userName'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      phoneNumber: map['phoneNumber'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      authProvider: AuthProviderJson.fromJson(map['authProvider'] as String?),
      role: UserRoleJson.fromJson(map['role'] as String?),
      status: UserStatusJson.fromJson(map['status'] as String?),
      isLandlord: map['isLandlord'] as bool? ?? false,
      fcmTokens: _parseStringList(map['fcmTokens']),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(userId: $userId, userName: $userName, email: $email, phoneNumber: $phoneNumber, avatarUrl: $avatarUrl, authProvider: ${authProvider.toJson()}, role: ${role.toJson()}, status: ${status.toJson()}, isLandlord: $isLandlord, fcmTokens: $fcmTokens, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    return value.whereType<String>().toList();
  }
}
