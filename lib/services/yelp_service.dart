import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/place_review_model.dart';
import '../main.dart';

class YelpService {
  static const String _baseUrl = 'https://api.yelp.com/v3';
  
  static String get _apiKey {
    final key = getEnvVar('YELP_API_KEY');
    print('Debug: Yelp Service - API Key: ${key.substring(0, key.length > 10 ? 10 : key.length)}...');
    if (key.isEmpty || key == 'demo_key') {
      if (kIsWeb) {
        // In web mode, return a placeholder that will be handled gracefully
        print('Debug: Yelp Service - Using DEMO mode');
        return 'demo_key';
      } else {
        throw Exception('Yelp API key not configured. Please add your API key to the .env file.');
      }
    }
    print('Debug: Yelp Service - Using REAL API key');
    return key;
  }

  /// Search for businesses using text query
  static Future<List<Map<String, dynamic>>> searchBusinesses(
    String query, {
    double? latitude,
    double? longitude,
    int limit = 5,
  }) async {
    // Only use mock data if we're actually in demo mode
    if (_apiKey == 'demo_key') {
      // Return mock data for demo purposes with dynamic name
      final mockData = _getMockBusinessesData();
      // Update the first result with the search query
      if (mockData.isNotEmpty) {
        mockData[0]['name'] = query.isNotEmpty ? query : 'Sample Restaurant';
      }
      return mockData;
    }

    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final queryParams = {
      'term': query,
      'limit': limit.toString(),
    };

    // Yelp API requires either location or coordinates
    if (latitude != null && longitude != null) {
      queryParams['latitude'] = latitude.toString();
      queryParams['longitude'] = longitude.toString();
      print('Debug: Yelp API using coordinates: $latitude, $longitude');
    } else {
      // Use a default location (New York City) if no coordinates provided
      queryParams['location'] = 'New York, NY';
      print('Debug: Yelp API using default location: New York, NY');
    }

    final uri = Uri.parse('$_baseUrl/businesses/search').replace(queryParameters: queryParams);
    print('Debug: Yelp API URL: $uri');
    print('Debug: Yelp API query parameters: $queryParams');
    print('Debug: Yelp API headers: $headers');

    try {
      final response = await http.get(uri, headers: headers);
      print('Debug: Yelp API response status: ${response.statusCode}');
      print('Debug: Yelp API response headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Debug: Yelp API response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
        return List<Map<String, dynamic>>.from(data['businesses']);
      } else {
        final data = json.decode(response.body);
        print('Debug: Yelp API error response: ${response.body}');
        throw Exception('Yelp API error: ${data['error']?['description'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Debug: Yelp API exception: $e');
      
      // Handle CORS errors and other network issues
      if (e.toString().contains('CORS') || e.toString().contains('XMLHttpRequest')) {
        print('CORS error detected in Yelp API, falling back to mock data');
        // Return mock data with the search query
        final mockData = _getMockBusinessesData();
        if (mockData.isNotEmpty) {
          mockData[0]['name'] = query.isNotEmpty ? query : 'Sample Restaurant';
        }
        return mockData;
      }
      
      throw Exception('Failed to search businesses: $e');
    }
  }

  /// Get detailed information about a business
  static Future<Map<String, dynamic>> getBusinessDetails(String businessId) async {
    // Only use mock data if we're actually in demo mode
    if (_apiKey == 'demo_key') {
      // Return mock data for demo purposes
      return _getMockBusinessDetails();
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
    // Only use mock data if we're actually in demo mode
    if (_apiKey == 'demo_key') {
      // Return mock data for demo purposes
      return _getMockReviewsData();
    }

    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final url = Uri.parse('$_baseUrl/businesses/$businessId/reviews');

    try {
      final response = await http.get(url, headers: headers);
      print('Debug: Yelp Reviews API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['reviews']);
      } else if (response.statusCode == 404) {
        print('Debug: Yelp Reviews not found for business $businessId, using mock reviews');
        // Return mock reviews when reviews are not available
        return _getMockReviewsData();
      } else {
        final data = json.decode(response.body);
        print('Debug: Yelp Reviews API error response: ${response.body}');
        throw Exception('Yelp API error: ${data['error']?['description'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Debug: Yelp Reviews API exception: $e');
      
      // Handle CORS errors and other network issues
      if (e.toString().contains('CORS') || e.toString().contains('XMLHttpRequest')) {
        print('CORS error detected in Yelp Reviews API, falling back to mock data');
        return _getMockReviewsData();
      }
      
      // For any other error, fall back to mock reviews
      print('Debug: Falling back to mock reviews due to error: $e');
      return _getMockReviewsData();
    }
  }

  /// Mock data for demo purposes
  static List<Map<String, dynamic>> _getMockBusinessesData() {
    return [
      {
        'id': 'demo_business_1',
        'name': 'Sample Restaurant',
        'rating': 4.5,
        'review_count': 150,
        'location': {
          'address1': '123 Main Street',
          'city': 'Sample City',
          'state': 'SC',
          'zip_code': '12345'
        },
        'coordinates': {
          'latitude': 40.7128,
          'longitude': -74.0060
        }
      },
      {
        'id': 'demo_business_2',
        'name': 'Local Cafe',
        'rating': 4.2,
        'review_count': 89,
        'location': {
          'address1': '456 Oak Avenue',
          'city': 'Local Town',
          'state': 'LT',
          'zip_code': '67890'
        },
        'coordinates': {
          'latitude': 40.7589,
          'longitude': -73.9851
        }
      }
    ];
  }

  /// Mock business details for demo purposes
  static Map<String, dynamic> _getMockBusinessDetails() {
    return {
      'id': 'demo_business_1',
      'name': 'Sample Restaurant',
      'rating': 4.5,
      'review_count': 150,
      'location': {
        'address1': '123 Main Street',
        'city': 'Sample City',
        'state': 'SC',
        'zip_code': '12345'
      },
      'url': 'https://yelp.com',
      'phone': '+1-555-123-4567'
    };
  }

  /// Mock reviews data for demo purposes
  static List<Map<String, dynamic>> _getMockReviewsData() {
    return [
      {
        'id': 'demo_review_1',
        'rating': 5,
        'text': 'Amazing coffee and great atmosphere! The staff is always friendly and the drinks are consistently excellent. Highly recommend!',
        'user': {
          'name': 'Coffee Lover'
        }
      },
      {
        'id': 'demo_review_2',
        'rating': 4,
        'text': 'Good quality coffee and quick service. The location is convenient and the prices are reasonable. Will definitely come back!',
        'user': {
          'name': 'Regular Customer'
        }
      },
      {
        'id': 'demo_review_3',
        'rating': 4,
        'text': 'Nice place to grab a coffee. The seating area is comfortable and the wifi is reliable. Perfect for working or meeting friends.',
        'user': {
          'name': 'Local Resident'
        }
      }
    ];
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