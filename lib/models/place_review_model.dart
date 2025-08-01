class PlaceReviewModel {
  final String name;
  final String? address;
  final double? googleRating;
  final int? googleReviews;
  final double? yelpRating;
  final int? yelpReviews;
  final List<String> summaryTags;
  final String? googleUrl;
  final String? yelpUrl;
  final String? website;
  final String? facebookUrl;
  final String? instagramUrl;
  final List<String> googleReviewSnippets;
  final List<String> yelpReviewSnippets;

  PlaceReviewModel({
    required this.name,
    this.address,
    this.googleRating,
    this.googleReviews,
    this.yelpRating,
    this.yelpReviews,
    this.summaryTags = const [],
    this.googleUrl,
    this.yelpUrl,
    this.website,
    this.facebookUrl,
    this.instagramUrl,
    this.googleReviewSnippets = const [],
    this.yelpReviewSnippets = const [],
  });

  // Calculate average rating across platforms
  double? get averageRating {
    List<double> ratings = [];
    if (googleRating != null) ratings.add(googleRating!);
    if (yelpRating != null) ratings.add(yelpRating!);
    
    if (ratings.isEmpty) return null;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  // Get total review count
  int get totalReviews {
    int total = 0;
    if (googleReviews != null) total += googleReviews!;
    if (yelpReviews != null) total += yelpReviews!;
    return total;
  }

  // Check if we have any data
  bool get hasData => googleRating != null || yelpRating != null;

  // Create a copy with updated fields
  PlaceReviewModel copyWith({
    String? name,
    String? address,
    double? googleRating,
    int? googleReviews,
    double? yelpRating,
    int? yelpReviews,
    List<String>? summaryTags,
    String? googleUrl,
    String? yelpUrl,
    String? website,
    String? facebookUrl,
    String? instagramUrl,
    List<String>? googleReviewSnippets,
    List<String>? yelpReviewSnippets,
  }) {
    return PlaceReviewModel(
      name: name ?? this.name,
      address: address ?? this.address,
      googleRating: googleRating ?? this.googleRating,
      googleReviews: googleReviews ?? this.googleReviews,
      yelpRating: yelpRating ?? this.yelpRating,
      yelpReviews: yelpReviews ?? this.yelpReviews,
      summaryTags: summaryTags ?? this.summaryTags,
      googleUrl: googleUrl ?? this.googleUrl,
      yelpUrl: yelpUrl ?? this.yelpUrl,
      website: website ?? this.website,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      googleReviewSnippets: googleReviewSnippets ?? this.googleReviewSnippets,
      yelpReviewSnippets: yelpReviewSnippets ?? this.yelpReviewSnippets,
    );
  }
} 