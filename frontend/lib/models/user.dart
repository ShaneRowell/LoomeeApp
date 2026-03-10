class User {
  final String id;
  final String email;
  final String name;
  final BodyMeasurements? bodyMeasurements;
  final String? avatarImage;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.bodyMeasurements,
    this.avatarImage,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      bodyMeasurements: json['bodyMeasurements'] != null
          ? BodyMeasurements.fromJson(json['bodyMeasurements'])
          : null,
      avatarImage: json['avatarImage'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
    };
  }
}

class BodyMeasurements {
  final double? chest;
  final double? waist;
  final double? hips;
  final double? height;
  final double? weight;

  BodyMeasurements({
    this.chest,
    this.waist,
    this.hips,
    this.height,
    this.weight,
  });

  factory BodyMeasurements.fromJson(Map<String, dynamic> json) {
    return BodyMeasurements(
      chest: (json['chest'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      hips: (json['hips'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }
}
