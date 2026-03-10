class FashionRecommendation {
  final List<String> accessories;
  final List<String> shoes;
  final List<String> complementaryItems;
  final List<String> colorMatches;
  final List<OutfitSuggestion> outfitSuggestions;
  final List<String> styleTips;

  FashionRecommendation({
    this.accessories = const [],
    this.shoes = const [],
    this.complementaryItems = const [],
    this.colorMatches = const [],
    this.outfitSuggestions = const [],
    this.styleTips = const [],
  });

  factory FashionRecommendation.fromJson(Map<String, dynamic> json) {
    final recs = json['recommendations'] ?? json;
    return FashionRecommendation(
      accessories: _toStringList(recs['accessories']),
      shoes: _toStringList(recs['shoes']),
      complementaryItems: _toStringList(recs['complementaryItems']),
      colorMatches: _toStringList(recs['colorMatches']),
      outfitSuggestions: (recs['outfitSuggestions'] as List<dynamic>?)
              ?.map((o) => OutfitSuggestion.fromJson(o))
              .toList() ??
          [],
      styleTips: _toStringList(recs['styleTips']),
    );
  }

  static List<String> _toStringList(dynamic list) {
    if (list is List) return list.map((e) => e.toString()).toList();
    return [];
  }
}

class OutfitSuggestion {
  final String name;
  final List<String> items;
  final String occasion;

  OutfitSuggestion({
    required this.name,
    this.items = const [],
    required this.occasion,
  });

  factory OutfitSuggestion.fromJson(Map<String, dynamic> json) {
    return OutfitSuggestion(
      name: json['name'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      occasion: json['occasion'] ?? '',
    );
  }
}

class PersonalizedRecommendation {
  final List<String> forYou;
  final List<String> trendingNow;
  final List<String> buildYourWardrobe;

  PersonalizedRecommendation({
    this.forYou = const [],
    this.trendingNow = const [],
    this.buildYourWardrobe = const [],
  });

  factory PersonalizedRecommendation.fromJson(Map<String, dynamic> json) {
    final recs = json['recommendations'] ?? json;
    return PersonalizedRecommendation(
      forYou: _toStringList(recs['forYou']),
      trendingNow: _toStringList(recs['trendingNow']),
      buildYourWardrobe: _toStringList(recs['buildYourWardrobe']),
    );
  }

  static List<String> _toStringList(dynamic list) {
    if (list is List) return list.map((e) => e.toString()).toList();
    return [];
  }
}

class CompleteOutfit {
  final String name;
  final String occasion;
  final String style;
  final OutfitItems items;
  final double totalPrice;
  final String reasoning;

  CompleteOutfit({
    required this.name,
    required this.occasion,
    required this.style,
    required this.items,
    required this.totalPrice,
    required this.reasoning,
  });

  factory CompleteOutfit.fromJson(Map<String, dynamic> json) {
    return CompleteOutfit(
      name: json['name'] ?? '',
      occasion: json['occasion'] ?? '',
      style: json['style'] ?? '',
      items: OutfitItems.fromJson(json['items'] ?? {}),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      reasoning: json['reasoning'] ?? '',
    );
  }
}

class OutfitItems {
  final String? top;
  final String? bottom;
  final String? shoes;
  final List<String> accessories;

  OutfitItems({this.top, this.bottom, this.shoes, this.accessories = const []});

  factory OutfitItems.fromJson(Map<String, dynamic> json) {
    return OutfitItems(
      top: json['top'],
      bottom: json['bottom'],
      shoes: json['shoes'],
      accessories: (json['accessories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
