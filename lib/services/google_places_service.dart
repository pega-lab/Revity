import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/place_review_model.dart';
import '../main.dart';

class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  static String get _apiKey {
    final key = getEnvVar('GOOGLE_MAPS_API_KEY');
    print('Debug: Google Places Service - API Key: ${key.substring(0, key.length > 10 ? 10 : key.length)}...');
    if (key.isEmpty || key == 'demo_key') {
      if (kIsWeb) {
        // In web mode, return a placeholder that will be handled gracefully
        print('Debug: Google Places Service - Using DEMO mode');
        return 'demo_key';
      } else {
        throw Exception('Google Maps API key not configured. Please add your API key to the .env file.');
      }
    }
    print('Debug: Google Places Service - Using REAL API key');
    return key;
  }

  /// Search for places using text query
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    // Only use mock data if we're actually in demo mode
    if (_apiKey == 'demo_key') {
      // Return mock data for demo purposes with dynamic name
      final mockData = _getMockPlacesData();
      // Update the first result with the search query
      if (mockData.isNotEmpty) {
        mockData[0]['name'] = query.isNotEmpty ? query : 'Sample Restaurant';
      }
      return mockData;
    }

    final url = Uri.parse(
      '$_baseUrl/textsearch/json?query=${Uri.encodeComponent(query)}&key=$_apiKey'
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Google Places API error: ${data['status']}');
      }
    } catch (e) {
      // Handle CORS errors and other network issues
      print('Google Places API call failed: $e');
      if (e.toString().contains('CORS') || e.toString().contains('XMLHttpRequest')) {
        print('CORS error detected, falling back to mock data');
        // Return mock data with the search query
        final mockData = _getMockPlacesData();
        if (mockData.isNotEmpty) {
          mockData[0]['name'] = query.isNotEmpty ? query : 'Sample Restaurant';
        }
        return mockData;
      }
      throw Exception('Failed to search places: $e');
    }
  }

  /// Search for places near a location
  static Future<List<Map<String, dynamic>>> searchNearby(
    double lat, 
    double lng, 
    {int radius = 1500, String type = 'restaurant'}
  ) async {
    // Only use mock data if we're actually in demo mode
    if (_apiKey == 'demo_key') {
      // Return mock data for demo purposes
      return _getMockPlacesData();
    }

    final url = Uri.parse(
      '$_baseUrl/nearbysearch/json?location=$lat,$lng&radius=$radius&type=$type&key=$_apiKey'
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Google Places API error: ${data['status']}');
      }
    } catch (e) {
      // Handle CORS errors and other network issues
      print('Google Places nearby search failed: $e');
      if (e.toString().contains('CORS') || e.toString().contains('XMLHttpRequest')) {
        print('CORS error detected, falling back to mock data');
        return _getMockPlacesData();
      }
      throw Exception('Failed to search nearby places: $e');
    }
  }

  /// Get detailed information about a place
  static Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    // Only use mock data if we're actually in demo mode
    if (_apiKey == 'demo_key') {
      // Return mock data for demo purposes
      return _getMockPlaceDetails();
    }

    final fields = 'name,formatted_address,rating,user_ratings_total,reviews,url,website';
    final url = Uri.parse(
      '$_baseUrl/details/json?place_id=$placeId&fields=$fields&key=$_apiKey'
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        return data['result'];
      } else {
        throw Exception('Google Places API error: ${data['status']}');
      }
    } catch (e) {
      // Handle CORS errors and other network issues
      print('Google Places details failed: $e');
      if (e.toString().contains('CORS') || e.toString().contains('XMLHttpRequest')) {
        print('CORS error detected, falling back to mock data');
        return _getMockPlaceDetails();
      }
      throw Exception('Failed to get place details: $e');
    }
  }

  /// Mock data for demo purposes
  static List<Map<String, dynamic>> _getMockPlacesData() {
    return [
      {
        'place_id': 'demo_place_1',
        'name': 'Sample Restaurant',
        'formatted_address': '123 Main Street, Sample City',
        'rating': 4.5,
        'user_ratings_total': 150,
        'geometry': {
          'location': {
            'lat': 40.7128,
            'lng': -74.0060
          }
        }
      },
      {
        'place_id': 'demo_place_2',
        'name': 'Local Cafe',
        'formatted_address': '456 Oak Avenue, Local Town',
        'rating': 4.2,
        'user_ratings_total': 89,
        'geometry': {
          'location': {
            'lat': 40.7589,
            'lng': -73.9851
          }
        }
      }
    ];
  }

  /// Mock place details for demo purposes
  static Map<String, dynamic> _getMockPlaceDetails() {
    return {
      'name': 'Sample Restaurant',
      'formatted_address': '123 Main Street, Sample City',
      'rating': 4.5,
      'user_ratings_total': 150,
      'url': 'https://maps.google.com',
      'website': 'https://example.com',
      'reviews': [
        {
          'text': 'Great food and atmosphere! Highly recommend.',
          'rating': 5
        },
        {
          'text': 'Good service and tasty dishes.',
          'rating': 4
        },
        {
          'text': 'Nice place with friendly staff.',
          'rating': 4
        }
      ]
    };
  }

  /// Convert Google Places data to PlaceReviewModel
  static PlaceReviewModel parsePlaceData(Map<String, dynamic> placeData) {
    final reviews = placeData['reviews'] as List<dynamic>? ?? [];
    final reviewSnippets = reviews
        .take(5)
        .map((review) => review['text'] as String)
        .toList();

    return PlaceReviewModel(
      name: placeData['name'] ?? '',
      address: placeData['formatted_address'],
      googleRating: placeData['rating']?.toDouble(),
      googleReviews: placeData['user_ratings_total'],
      googleUrl: placeData['url'],
      website: placeData['website'],
      googleReviewSnippets: reviewSnippets,
    );
  }

  /// Search and get detailed info for a place
  static Future<PlaceReviewModel?> searchAndGetDetails(String query) async {
    try {
      final places = await searchPlaces(query);
      if (places.isNotEmpty) {
        final placeId = places.first['place_id'];
        final details = await getPlaceDetails(placeId);
        return parsePlaceData(details);
      }
      return null;
    } catch (e) {
      print('Error searching place: $e');
      return null;
    }
  }
} 