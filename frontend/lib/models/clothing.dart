class Clothing {
  final String id;
  final String name;
  final String description;
  final String category;
  final String brand;
  final double price;
  final String currency;
  final List<ClothingSize> sizes;
  final List<ClothingColor> colors;
  final List<String> images;
  final String gender;
  final String? material;
  final List<String> tags;
  final bool isActive;
  final DateTime? createdAt;

  Clothing({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.brand,
    required this.price,
    this.currency = 'LKR',
    this.sizes = const [],
    this.colors = const [],
    this.images = const [],
    required this.gender,
    this.material,
    this.tags = const [],
    this.isActive = true,
    this.createdAt,
  });

  String get primaryImage =>
      images.isNotEmpty ? images.first : '';

  factory Clothing.fromJson(Map<String, dynamic> json) {
    return Clothing(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'LKR',
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((s) => ClothingSize.fromJson(s))
              .toList() ??
          [],
      colors: (json['colors'] as List<dynamic>?)
              ?.map((c) => ClothingColor.fromJson(c))
              .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
              ?.map((i) => i.toString())
              .toList() ??
          [],
      gender: json['gender'] ?? 'unisex',
      material: json['material'],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'brand': brand,
      'price': price,
      'currency': currency,
      'sizes': sizes.map((s) => s.toJson()).toList(),
      'colors': colors.map((c) => c.toJson()).toList(),
      'images': images,
      'gender': gender,
      'material': material,
      'tags': tags,
      'isActive': isActive,
    };
  }
}

class ClothingSize {
  final String size;
  final SizeMeasurements? measurements;
  final int stock;

  ClothingSize({
    required this.size,
    this.measurements,
    this.stock = 0,
  });

  factory ClothingSize.fromJson(Map<String, dynamic> json) {
    return ClothingSize(
      size: json['size'] ?? '',
      measurements: json['measurements'] != null
          ? SizeMeasurements.fromJson(json['measurements'])
          : null,
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'measurements': measurements?.toJson(),
      'stock': stock,
    };
  }
}

class SizeMeasurements {
  final double? chest;
  final double? waist;
  final double? hips;
  final double? length;

  SizeMeasurements({this.chest, this.waist, this.hips, this.length});

  factory SizeMeasurements.fromJson(Map<String, dynamic> json) {
    return SizeMeasurements(
      chest: (json['chest'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      hips: (json['hips'] as num?)?.toDouble(),
      length: (json['length'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'length': length,
    };
  }
}

class ClothingColor {
  final String name;
  final String? hex;
  final String? imageUrl;

  ClothingColor({required this.name, this.hex, this.imageUrl});

  factory ClothingColor.fromJson(Map<String, dynamic> json) {
    return ClothingColor(
      name: json['name'] ?? '',
      hex: json['hex'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hex': hex,
      'imageUrl': imageUrl,
    };
  }
}
