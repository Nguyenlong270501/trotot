class LandlordSummaryModel {
  const LandlordSummaryModel({
    required this.userName,
    this.phoneNumber,
    this.avatarUrl,
    required this.createdAt,
  });

  final String userName;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LandlordSummaryModel.fromMap(Map<String, dynamic> map) {
    return LandlordSummaryModel(
      userName: map['userName']?.toString() ?? '',
      phoneNumber: map['phoneNumber']?.toString(),
      avatarUrl: map['avatarUrl']?.toString(),
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value != null) {
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
