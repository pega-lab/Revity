import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/place_review_model.dart';
import '../services/review_aggregator_service.dart';
import '../widgets/review_summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  Position? _currentPosition;
  PlaceReviewModel? _currentPlace;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage = 'Location services are not enabled';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permission denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Location permissions are permanently denied';
      });
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = pos;
        _controller.text = '${pos.latitude}, ${pos.longitude}';
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: $e';
      });
    }
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a place name or use current location';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPlace = null;
    });

    try {
      PlaceReviewModel? place;
      
      // If we have current location and the query looks like coordinates, search nearby
      if (_currentPosition != null && 
          (query.contains(',') || query.contains('${_currentPosition!.latitude}') || query.contains('${_currentPosition!.longitude}'))) {
        // Search for nearby places
        final nearbyPlaces = await ReviewAggregatorService.searchNearbyPlaces(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          limit: 1,
        );
        
        if (nearbyPlaces.isNotEmpty) {
          place = nearbyPlaces.first;
        }
      } else {
        // Regular search by name
        place = await ReviewAggregatorService.aggregateReviews(
          query,
          latitude: _currentPosition?.latitude,
          longitude: _currentPosition?.longitude,
        );
      }

      setState(() {
        _isLoading = false;
        if (place != null) {
          _currentPlace = place;
        } else {
          _errorMessage = 'No reviews found for "$query". Try searching for any restaurant name to see demo results.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        final errorMsg = e.toString();
        if (errorMsg.contains('API key not configured')) {
          _errorMessage = 'API keys not configured. Try searching for any restaurant name to see demo results.';
        } else {
          _errorMessage = 'Error searching for reviews: $e. Try searching for any restaurant name to see demo results.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen build called'); // Debug print
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revity'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search input
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter a place name',
                hintText: 'e.g., Starbucks, McDonald\'s, Pizza Hut',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 12),

            // Location and search buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use Current Location'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                ),
              ],
            ),

            // Current position display
            if (_currentPosition != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green[600], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Location: ${_currentPosition!.latitude.toStringAsFixed(4)}, '
                          '${_currentPosition!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[600], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Results section
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Searching for reviews...'),
                        ],
                      ),
                    )
                  : _currentPlace != null
                      ? SingleChildScrollView(
                          child: ReviewSummaryCard(
                            place: _currentPlace!,
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Search for a place to see aggregated reviews',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
