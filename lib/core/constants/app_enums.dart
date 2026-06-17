enum UserRole { tenant, landlord, admin }

extension UserRoleJson on UserRole {
  String toJson() => name;

  static UserRole fromJson(String? value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.tenant,
    );
  }
}


enum UserStatus { active, blocked }

extension UserStatusJson on UserStatus {
  String toJson() => name;
  static UserStatus fromJson(String? value) {
    return UserStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserStatus.active,
    );
  }
}


enum AuthProvider { google, facebook, email }

extension AuthProviderJson on AuthProvider {
  String toJson() => name;
  static AuthProvider fromJson(String? value) {
    return AuthProvider.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AuthProvider.email,
    );
  }
}
