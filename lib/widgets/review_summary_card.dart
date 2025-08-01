import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/place_review_model.dart';

class ReviewSummaryCard extends StatelessWidget {
  final PlaceReviewModel place;
  final VoidCallback? onTap;

  const ReviewSummaryCard({
    Key? key,
    required this.place,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Place name and address
              Text(
                place.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (place.address != null) ...[
                const SizedBox(height: 4),
                Text(
                  place.address!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Ratings section
              Row(
                children: [
                  // Average rating
                  if (place.averageRating != null) ...[
                    _buildRatingChip(
                      'Average',
                      place.averageRating!,
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // Total reviews
                  if (place.totalReviews > 0)
                    _buildReviewCountChip(place.totalReviews),
                ],
              ),
              const SizedBox(height: 12),

              // Platform-specific ratings
              Row(
                children: [
                  if (place.googleRating != null)
                    Expanded(
                      child: _buildPlatformRating(
                        'Google',
                        place.googleRating!,
                        place.googleReviews ?? 0,
                        Colors.red,
                        place.googleUrl,
                      ),
                    ),
                  if (place.googleRating != null && place.yelpRating != null)
                    const SizedBox(width: 8),
                  if (place.yelpRating != null)
                    Expanded(
                      child: _buildPlatformRating(
                        'Yelp',
                        place.yelpRating!,
                        place.yelpReviews ?? 0,
                        Colors.orange,
                        place.yelpUrl,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Summary tags
              if (place.summaryTags.isNotEmpty) ...[
                Text(
                  'What people say:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: place.summaryTags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.blue[50],
                    side: BorderSide(color: Colors.blue[200]!),
                  )).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Action buttons
              Row(
                children: [
                  if (place.googleUrl != null)
                    Expanded(
                      child: _buildActionButton(
                        'View on Google',
                        Icons.map,
                        Colors.red,
                        () => _launchUrl(place.googleUrl!),
                      ),
                    ),
                  if (place.googleUrl != null && place.yelpUrl != null)
                    const SizedBox(width: 8),
                  if (place.yelpUrl != null)
                    Expanded(
                      child: _buildActionButton(
                        'View on Yelp',
                        Icons.star,
                        Colors.orange,
                        () => _launchUrl(place.yelpUrl!),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingChip(String label, double rating, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            '$label: ${rating.toStringAsFixed(1)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCountChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        '$count reviews',
        style: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPlatformRating(
    String platform,
    double rating,
    int reviews,
    Color color,
    String? url,
  ) {
    return InkWell(
      onTap: url != null ? () => _launchUrl(url) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  platform,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              '$reviews reviews',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
} 