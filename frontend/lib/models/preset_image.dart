class PresetImage {
  final String id;
  final String userId;
  final String imageUrl;
  final String imageType;
  final bool isDefault;
  final DateTime? uploadedAt;

  PresetImage({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.imageType = 'front',
    this.isDefault = false,
    this.uploadedAt,
  });

  factory PresetImage.fromJson(Map<String, dynamic> json) {
    return PresetImage(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      imageType: json['imageType'] ?? 'front',
      isDefault: json['isDefault'] ?? false,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'])
          : null,
    );
  }
}
