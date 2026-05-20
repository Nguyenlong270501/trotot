import 'package:cloud_firestore/cloud_firestore.dart';
import 'landlord_summary_model.dart';
import 'room_model.dart';

class PropertyModel {
  final String propertyId;
  final String landlordId;
  final LandlordSummaryModel? landlordSummary;

  // Thông tin chung
  final String title;
  final String description;
  final List<String> propertyTypes;

  /// Giá thuê tối thiểu/tối đa trong các phòng còn trống (đồng bộ bởi Cloud Function).
  final int? minRoomPrice;
  final int? maxRoomPrice;

  // Vị trí
  final String city;
  final String ward;
  final String streetAddress;
  final GeoPoint? location;

  // Chi phí & Tiện ích
  final int electricityPrice;
  final int waterPrice;
  final int? wifiPrice;
  final int? serviceFee;
  final int? parkingFee;
  final String? serviceDescription;
  final List<String>? facilities;
  final List<String>? rules;
  final String? rulesDescription;
  final String? curfewTime;
  final List<String>? imageUrls;

  // Quản lý & Thống kê
  final double ratingAverage;
  final int totalReviews;
  final Map<String, int> ratingDistribution;
  final int minimumRentalDuration;

  // Dữ liệu mở rộng (không lưu trực tiếp vào collection properties)
  final List<RoomModel>? rooms;

  // Thời gian
  final DateTime createdAt;
  final DateTime updatedAt;

  PropertyModel({
    required this.propertyId,
    required this.landlordId,
    this.landlordSummary,
    required this.title,
    required this.description,
    required this.propertyTypes,
    this.minRoomPrice,
    this.maxRoomPrice,
    required this.minimumRentalDuration,
    required this.city,
    required this.ward,
    required this.streetAddress,
    this.location,
    required this.electricityPrice,
    required this.waterPrice,
    this.wifiPrice,
    this.serviceFee,
    this.parkingFee,
    this.serviceDescription,
    this.facilities,
    this.rules,
    this.rulesDescription,
    this.curfewTime,
    this.imageUrls,
    this.ratingAverage = 0.0,
    this.totalReviews = 0,
    this.ratingDistribution = const {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
    this.rooms,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayPropertyType {
    if (propertyTypes.isEmpty) return '';

    return propertyTypes
        .map((type) => type.trim())
        .where((type) => type.isNotEmpty)
        .join(' , ');
  }

  String get propertyType => displayPropertyType;

  PropertyModel copyWith({
    String? propertyId,
    String? landlordId,
    LandlordSummaryModel? landlordSummary,
    String? title,
    String? description,
    List<String>? propertyTypes,
    int? minRoomPrice,
    int? maxRoomPrice,
    int? minimumRentalDuration,
    String? city,
    String? ward,
    String? streetAddress,
    GeoPoint? location,
    int? electricityPrice,
    int? waterPrice,
    int? wifiPrice,
    int? parkingFee,
    int? serviceFee,
    String? serviceDescription,
    List<String>? facilities,
    List<String>? rules,
    String? rulesDescription,
    String? curfewTime,
    List<String>? imageUrls,
    double? ratingAverage,
    int? totalReviews,
    Map<String, int>? ratingDistribution,
    List<RoomModel>? rooms,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyModel(
      propertyId: propertyId ?? this.propertyId,
      landlordId: landlordId ?? this.landlordId,
      landlordSummary: landlordSummary ?? this.landlordSummary,
      title: title ?? this.title,
      description: description ?? this.description,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      minRoomPrice: minRoomPrice ?? this.minRoomPrice,
      maxRoomPrice: maxRoomPrice ?? this.maxRoomPrice,
      minimumRentalDuration: minimumRentalDuration ?? this.minimumRentalDuration,
      city: city ?? this.city,
      ward: ward ?? this.ward,
      streetAddress: streetAddress ?? this.streetAddress,
      location: location ?? this.location,
      electricityPrice: electricityPrice ?? this.electricityPrice,
      waterPrice: waterPrice ?? this.waterPrice,
      wifiPrice: wifiPrice ?? this.wifiPrice,
      serviceFee: serviceFee ?? this.serviceFee,
      parkingFee: parkingFee ?? this.parkingFee,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      facilities: facilities ?? this.facilities,
      rules: rules ?? this.rules,
      rulesDescription: rulesDescription ?? this.rulesDescription,
      curfewTime: curfewTime ?? this.curfewTime,
      imageUrls: imageUrls ?? this.imageUrls,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      totalReviews: totalReviews ?? this.totalReviews,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
      rooms: rooms ?? this.rooms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'landlordId': landlordId,
      'landlordSummary': landlordSummary?.toMap(),
      'title': title,
      'description': description,
      'propertyTypes': propertyTypes,
      'minRoomPrice': minRoomPrice,
      'maxRoomPrice': maxRoomPrice,
      'minimumRentalDuration': minimumRentalDuration,
      'city': city,
      'ward': ward,
      'streetAddress': streetAddress,
      'location': location,
      'electricityPrice': electricityPrice,
      'waterPrice': waterPrice,
      'wifiPrice': wifiPrice,
      'serviceFee': serviceFee,
      'parkingFee': parkingFee,
      'serviceDescription': serviceDescription,
      'facilities': facilities,
      'rules': rules,
      'rulesDescription': rulesDescription,
      'curfewTime': curfewTime,
      'imageUrls': imageUrls,
      'ratingAverage': ratingAverage,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory PropertyModel.fromMap(Map<String, dynamic> map) {
    return PropertyModel(
      propertyId: map['propertyId'] ?? '',
      landlordId: map['landlordId'] ?? '',
      landlordSummary: _parseLandlordSummary(map['landlordSummary']),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      propertyTypes: _parsePropertyTypes(map),
      minRoomPrice: _parseOptionalInt(map['minRoomPrice']),
      maxRoomPrice: _parseOptionalInt(map['maxRoomPrice']),
      minimumRentalDuration: map['minimumRentalDuration'] ?? 0,
      city: map['city'] ?? '',
      ward: map['ward'] ?? '',
      streetAddress: map['streetAddress'] ?? '',
      location: _parseGeoPoint(map['location']),
      electricityPrice: (map['electricityPrice'] ?? 0).toInt(),
      waterPrice: (map['waterPrice'] ?? 0).toInt(),
      wifiPrice: map['wifiPrice']?.toInt(),
      serviceFee: map['serviceFee']?.toInt(),
      parkingFee: map['parkingFee']?.toInt(),
      serviceDescription: map['serviceDescription'] ?? '',
      facilities: List<String>.from(map['facilities'] ?? []),
      rules: List<String>.from(map['rules'] ?? []),
      rulesDescription: map['rulesDescription'] ?? '',
      curfewTime: map['curfewTime'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      ratingAverage: (map['ratingAverage'] ?? 0).toDouble(),
      totalReviews: map['totalReviews']?.toInt() ?? 0,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      ratingDistribution: Map<String, int>.from(
        map['ratingDistribution'] ?? {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
      ),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static GeoPoint? _parseGeoPoint(dynamic value) {
    if (value is GeoPoint) return value;
    if (value is Map) {
      final lat = (value['latitude'] ?? value['_latitude'] ?? 0).toDouble();
      final lng = (value['longitude'] ?? value['_longitude'] ?? 0).toDouble();
      return GeoPoint(lat, lng);
    }
    return null;
  }

  static int? _parseOptionalInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  static List<String> _parsePropertyTypes(Map<String, dynamic> map) {
    final rawTypes = map['propertyTypes'];
    if (rawTypes is List) {
      final normalized = <String>[];
      for (final type in rawTypes) {
        final text = type?.toString().trim() ?? '';
        if (text.isNotEmpty) {
          normalized.add(text);
        }
      }
      return normalized;
    }

    return const [];
  }

  static LandlordSummaryModel? _parseLandlordSummary(dynamic value) {
    if (value is Map<String, dynamic>) {
      return LandlordSummaryModel.fromMap(value);
    }
    if (value is Map) {
      return LandlordSummaryModel.fromMap(Map<String, dynamic>.from(value));
    }
    return null;
  }
}
