class TryOn {
  final String id;
  final String userId;
  final TryOnClothing? clothing;
  final TryOnPresetImage? presetImage;
  final String? clothingImageUrl;
  final String? resultImageUrl;
  final FitAnalysis? fitAnalysis;
  final String status;
  /// 0–100, written by the backend at each pipeline milestone.
  final int progress;
  /// Backend stage key — maps to a display label in the progress card.
  final String? currentStage;
  final String? errorMessage;
  final String? aiDescription;
  final String? recommendedSize;
  final DateTime? createdAt;
  final DateTime? completedAt;

  TryOn({
    required this.id,
    required this.userId,
    this.clothing,
    this.presetImage,
    this.clothingImageUrl,
    this.resultImageUrl,
    this.fitAnalysis,
    this.status = 'pending',
    this.progress = 0,
    this.currentStage,
    this.errorMessage,
    this.aiDescription,
    this.recommendedSize,
    this.createdAt,
    this.completedAt,
  });

  factory TryOn.fromJson(Map<String, dynamic> json) {
    return TryOn(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      clothing: json['clothingId'] is Map
          ? TryOnClothing.fromJson(json['clothingId'])
          : null,
      presetImage: json['presetImageId'] is Map
          ? TryOnPresetImage.fromJson(json['presetImageId'])
          : null,
      clothingImageUrl: json['clothingImageUrl'],
      resultImageUrl: json['resultImageUrl'],
      fitAnalysis: json['fitAnalysis'] != null
          ? FitAnalysis.fromJson(json['fitAnalysis'])
          : null,
      status: json['status'] ?? 'pending',
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      currentStage: json['currentStage'] as String?,
      errorMessage: json['errorMessage'],
      aiDescription: json['aiDescription'],
      recommendedSize: json['recommendedSize'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
    );
  }
}

class TryOnClothing {
  final String id;
  final String name;
  final String brand;
  final double price;
  final List<String> images;

  TryOnClothing({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.images = const [],
  });

  factory TryOnClothing.fromJson(Map<String, dynamic> json) {
    return TryOnClothing(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>?)
              ?.map((i) => i.toString())
              .toList() ??
          [],
    );
  }
}

class TryOnPresetImage {
  final String id;
  final String imageUrl;
  final String imageType;

  TryOnPresetImage({
    required this.id,
    required this.imageUrl,
    this.imageType = 'front',
  });

  factory TryOnPresetImage.fromJson(Map<String, dynamic> json) {
    return TryOnPresetImage(
      id: json['_id'] ?? json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      imageType: json['imageType'] ?? 'front',
    );
  }
}

class FitAnalysis {
  final String overallFit;
  final List<String> tightAreas;
  final List<String> looseAreas;
  final List<String> recommendations;
  final double? confidence;

  FitAnalysis({
    required this.overallFit,
    this.tightAreas = const [],
    this.looseAreas = const [],
    this.recommendations = const [],
    this.confidence,
  });

  factory FitAnalysis.fromJson(Map<String, dynamic> json) {
    return FitAnalysis(
      overallFit: json['overallFit'] ?? 'unknown',
      tightAreas: (json['tightAreas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      looseAreas: (json['looseAreas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}
