import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/place_review_model.dart';

class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Search for places using text query
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (_apiKey.isEmpty) {
      throw Exception('Google Maps API key not found');
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
      throw Exception('Failed to search places: $e');
    }
  }

  /// Search for places near a location
  static Future<List<Map<String, dynamic>>> searchNearby(
    double lat, 
    double lng, 
    {int radius = 1500, String type = 'restaurant'}
  ) async {
    if (_apiKey.isEmpty) {
      throw Exception('Google Maps API key not found');
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
      throw Exception('Failed to search nearby places: $e');
    }
  }

  /// Get detailed information about a place
  static Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    if (_apiKey.isEmpty) {
      throw Exception('Google Maps API key not found');
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
      throw Exception('Failed to get place details: $e');
    }
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