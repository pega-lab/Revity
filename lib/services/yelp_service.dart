import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/place_review_model.dart';

class YelpService {
  static const String _baseUrl = 'https://api.yelp.com/v3';
  static String get _apiKey => dotenv.env['YELP_API_KEY'] ?? '';

  /// Search for businesses using text query
  static Future<List<Map<String, dynamic>>> searchBusinesses(
    String query, {
    double? latitude,
    double? longitude,
    int limit = 5,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Yelp API key not found');
    }

    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final queryParams = {
      'term': query,
      'limit': limit.toString(),
    };

    if (latitude != null && longitude != null) {
      queryParams['latitude'] = latitude.toString();
      queryParams['longitude'] = longitude.toString();
    }

    final uri = Uri.parse('$_baseUrl/businesses/search').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: headers);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(data['businesses']);
      } else {
        throw Exception('Yelp API error: ${data['error']?['description'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to search businesses: $e');
    }
  }

  /// Get detailed information about a business
  static Future<Map<String, dynamic>> getBusinessDetails(String businessId) async {
    if (_apiKey.isEmpty) {
      throw Exception('Yelp API key not found');
    }

    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final url = Uri.parse('$_baseUrl/businesses/$businessId');

    try {
      final response = await http.get(url, headers: headers);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception('Yelp API error: ${data['error']?['description'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to get business details: $e');
    }
  }

  /// Get reviews for a business
  static Future<List<Map<String, dynamic>>> getBusinessReviews(String businessId) async {
    if (_apiKey.isEmpty) {
      throw Exception('Yelp API key not found');
    }

    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final url = Uri.parse('$_baseUrl/businesses/$businessId/reviews');

    try {
      final response = await http.get(url, headers: headers);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(data['reviews']);
      } else {
        throw Exception('Yelp API error: ${data['error']?['description'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to get business reviews: $e');
    }
  }

  /// Convert Yelp business data to PlaceReviewModel
  static PlaceReviewModel parseBusinessData(Map<String, dynamic> businessData) {
    final reviews = businessData['reviews'] as List<dynamic>? ?? [];
    final reviewSnippets = reviews
        .take(3)
        .map((review) => review['text'] as String)
        .toList();

    return PlaceReviewModel(
      name: businessData['name'] ?? '',
      address: businessData['location']?['address1'],
      yelpRating: businessData['rating']?.toDouble(),
      yelpReviews: businessData['review_count'],
      yelpUrl: businessData['url'],
      yelpReviewSnippets: reviewSnippets,
    );
  }

  /// Search and get detailed info for a business
  static Future<PlaceReviewModel?> searchAndGetDetails(String query, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      final businesses = await searchBusinesses(query, latitude: latitude, longitude: longitude);
      if (businesses.isNotEmpty) {
        final businessId = businesses.first['id'];
        final details = await getBusinessDetails(businessId);
        final reviews = await getBusinessReviews(businessId);
        
        // Add reviews to the details
        details['reviews'] = reviews;
        
        return parseBusinessData(details);
      }
      return null;
    } catch (e) {
      print('Error searching business: $e');
      return null;
    }
  }
} 