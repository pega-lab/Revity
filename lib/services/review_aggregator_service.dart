import '../models/place_review_model.dart';
import 'google_places_service.dart';
import 'yelp_service.dart';

class ReviewAggregatorService {
  /// Aggregate reviews from Google and Yelp for a given place
  static Future<PlaceReviewModel?> aggregateReviews(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Fetch data from both APIs concurrently
      final googleFuture = GooglePlacesService.searchAndGetDetails(query);
      final yelpFuture = YelpService.searchAndGetDetails(
        query,
        latitude: latitude,
        longitude: longitude,
      );

      final results = await Future.wait([googleFuture, yelpFuture]);
      final googleData = results[0];
      final yelpData = results[1];

      // Start with Google data if available
      PlaceReviewModel? aggregatedData;
      
      if (googleData != null) {
        aggregatedData = googleData;
      } else if (yelpData != null) {
        aggregatedData = yelpData;
      } else {
        return null; // No data found from either source
      }

      // Merge Yelp data if available
      if (yelpData != null) {
        aggregatedData = aggregatedData!.copyWith(
          yelpRating: yelpData.yelpRating,
          yelpReviews: yelpData.yelpReviews,
          yelpUrl: yelpData.yelpUrl,
          yelpReviewSnippets: yelpData.yelpReviewSnippets,
        );
      }

      // Generate summary tags from review snippets
      final summaryTags = _generateSummaryTags(
        [...aggregatedData!.googleReviewSnippets, ...aggregatedData.yelpReviewSnippets],
      );

      return aggregatedData.copyWith(summaryTags: summaryTags);
    } catch (e) {
      print('Error aggregating reviews: $e');
      return null;
    }
  }

  /// Generate summary tags from review snippets
  static List<String> _generateSummaryTags(List<String> reviewSnippets) {
    if (reviewSnippets.isEmpty) return [];

    // Simple keyword extraction (can be enhanced with NLP later)
    final allText = reviewSnippets.join(' ').toLowerCase();
    
    // Common positive keywords
    final positiveKeywords = [
      'great', 'good', 'excellent', 'amazing', 'wonderful', 'fantastic',
      'delicious', 'tasty', 'fresh', 'friendly', 'helpful', 'fast',
      'clean', 'cozy', 'atmospheric', 'romantic', 'quiet', 'lively',
      'affordable', 'reasonable', 'worth', 'recommend', 'love', 'best'
    ];

    // Common negative keywords
    final negativeKeywords = [
      'bad', 'terrible', 'awful', 'disappointing', 'slow', 'rude',
      'dirty', 'expensive', 'overpriced', 'cold', 'bland', 'tasteless',
      'noisy', 'crowded', 'small', 'wait', 'avoid', 'worst'
    ];

    final allKeywords = [...positiveKeywords, ...negativeKeywords];
    final foundKeywords = <String>[];

    for (final keyword in allKeywords) {
      if (allText.contains(keyword) && !foundKeywords.contains(keyword)) {
        foundKeywords.add(keyword);
      }
    }

    // Return top 5 keywords
    return foundKeywords.take(5).toList();
  }

  /// Search for places near a location
  static Future<List<PlaceReviewModel>> searchNearbyPlaces(
    double latitude,
    double longitude, {
    int radius = 1500,
    String type = 'restaurant',
    int limit = 10,
  }) async {
    try {
      // Get nearby places from Google
      final googlePlaces = await GooglePlacesService.searchNearby(
        latitude,
        longitude,
        radius: radius,
        type: type,
      );

      final results = <PlaceReviewModel>[];

      // Process each place (limit to avoid too many API calls)
      for (int i = 0; i < googlePlaces.length && i < limit; i++) {
        final place = googlePlaces[i];
        final placeName = place['name'] as String? ?? '';
        
        if (placeName.isNotEmpty) {
          final aggregated = await aggregateReviews(
            placeName,
            latitude: latitude,
            longitude: longitude,
          );
          
          if (aggregated != null) {
            results.add(aggregated);
          }
        }
      }

      return results;
    } catch (e) {
      print('Error searching nearby places: $e');
      return [];
    }
  }
} 