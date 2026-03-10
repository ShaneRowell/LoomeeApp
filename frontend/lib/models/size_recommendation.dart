class SizeRecommendation {
  final ClothingInfo clothing;
  final UserMeasurementsInfo userMeasurements;
  final String recommendedSize;
  final int fitScore;
  final String fitDescription;
  final List<SizeOption> allSizes;
  final String advice;

  SizeRecommendation({
    required this.clothing,
    required this.userMeasurements,
    required this.recommendedSize,
    required this.fitScore,
    required this.fitDescription,
    required this.allSizes,
    required this.advice,
  });

  factory SizeRecommendation.fromJson(Map<String, dynamic> json) {
    return SizeRecommendation(
      clothing: ClothingInfo.fromJson(json['clothing'] ?? {}),
      userMeasurements:
          UserMeasurementsInfo.fromJson(json['userMeasurements'] ?? {}),
      recommendedSize: json['recommendedSize'] ?? '',
      fitScore: json['fitScore'] ?? 0,
      fitDescription: json['fitDescription'] ?? '',
      allSizes: (json['allSizes'] as List<dynamic>?)
              ?.map((s) => SizeOption.fromJson(s))
              .toList() ??
          [],
      advice: json['advice'] ?? '',
    );
  }
}

class ClothingInfo {
  final String id;
  final String name;
  final String brand;

  ClothingInfo({required this.id, required this.name, required this.brand});

  factory ClothingInfo.fromJson(Map<String, dynamic> json) {
    return ClothingInfo(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
    );
  }
}

class UserMeasurementsInfo {
  final double? chest;
  final double? waist;
  final double? hips;
  final double? height;

  UserMeasurementsInfo({this.chest, this.waist, this.hips, this.height});

  factory UserMeasurementsInfo.fromJson(Map<String, dynamic> json) {
    return UserMeasurementsInfo(
      chest: (json['chest'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      hips: (json['hips'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
    );
  }
}

class SizeOption {
  final String size;
  final int fitScore;
  final String fitDescription;
  final int stock;

  SizeOption({
    required this.size,
    required this.fitScore,
    required this.fitDescription,
    required this.stock,
  });

  factory SizeOption.fromJson(Map<String, dynamic> json) {
    return SizeOption(
      size: json['size'] ?? '',
      fitScore: json['fitScore'] ?? 0,
      fitDescription: json['fitDescription'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }
}

class BulkSizeRecommendation {
  final String clothingId;
  final String name;
  final String brand;
  final String recommendedSize;
  final int fitScore;
  final String fitDescription;

  BulkSizeRecommendation({
    required this.clothingId,
    required this.name,
    required this.brand,
    required this.recommendedSize,
    required this.fitScore,
    required this.fitDescription,
  });

  factory BulkSizeRecommendation.fromJson(Map<String, dynamic> json) {
    return BulkSizeRecommendation(
      clothingId: json['clothingId'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      recommendedSize: json['recommendedSize'] ?? '',
      fitScore: json['fitScore'] ?? 0,
      fitDescription: json['fitDescription'] ?? '',
    );
  }
}
