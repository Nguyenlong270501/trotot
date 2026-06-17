class Validators {
  static bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  static bool isValidPassword(String password) {
    final trimmed = password.trim();
    final hasMinLength = trimmed.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(trimmed);
    final hasDigit = RegExp(r'\d').hasMatch(trimmed);
    return hasMinLength && hasUppercase && hasDigit;
  }

  static bool isValidUsername(String username) {
    return username.trim().length >= 2 && username.trim().length <= 20;
  }

  static bool isValidFullName(String name) {
    final t = name.trim();
    return t.length >= 2 && t.length <= 100;
  }

  static bool isValidVietnamPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return false;
    return RegExp(r'^0\d{9}$').hasMatch(digits);
  }

  static bool isValidAddressLine(String address) {
    return address.trim().length >= 5;
  }
}
