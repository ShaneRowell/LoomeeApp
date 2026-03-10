class Measurement {
  final String? id;
  final String? userId;
  final double chest;
  final double waist;
  final double hips;
  final double height;
  final double weight;
  final double? shoulderWidth;
  final double? inseam;
  final String unit;
  final DateTime? lastUpdated;

  Measurement({
    this.id,
    this.userId,
    required this.chest,
    required this.waist,
    required this.hips,
    required this.height,
    required this.weight,
    this.shoulderWidth,
    this.inseam,
    this.unit = 'cm',
    this.lastUpdated,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] is Map
          ? json['userId']['_id']
          : json['userId'],
      chest: (json['chest'] as num).toDouble(),
      waist: (json['waist'] as num).toDouble(),
      hips: (json['hips'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      shoulderWidth: (json['shoulderWidth'] as num?)?.toDouble(),
      inseam: (json['inseam'] as num?)?.toDouble(),
      unit: json['unit'] ?? 'cm',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'height': height,
      'weight': weight,
      'unit': unit,
    };
    if (shoulderWidth != null) map['shoulderWidth'] = shoulderWidth;
    if (inseam != null) map['inseam'] = inseam;
    return map;
  }
}
