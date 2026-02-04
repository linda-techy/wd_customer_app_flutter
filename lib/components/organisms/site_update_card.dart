import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants.dart';
import '../animations/hover_card.dart';
import '../animations/scale_button.dart';

class SiteUpdateCard extends StatelessWidget {
  final String date;
  final String description;
  final List<String> imageUrls;
  final String workerCount;
  final String weather;
  final VoidCallback? onShare;
  final VoidCallback? onComment;

  const SiteUpdateCard({
    super.key,
    required this.date,
    required this.description,
    required this.imageUrls,
    this.workerCount = "5 Workers",
    this.weather = "28°C Sunny",
    this.onShare,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calendar_today,
                        size: 16, color: primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: blackColor,
                        ),
                      ),
                      const Text(
                        "Daily Site Log",
                        style: TextStyle(
                          fontSize: 12,
                          color: blackColor60,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildTag(Icons.wb_sunny_outlined, weather),
                  const SizedBox(width: 8),
                  _buildTag(Icons.people_outline, workerCount),
                ],
              ),
            ),

            // Image Carousel (Simple single image for now, can be expanded)
            if (imageUrls.isNotEmpty)
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: blackColor5,
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(imageUrls.first),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    if (imageUrls.length > 1)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "1/${imageUrls.length}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Description & Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: blackColor80,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ScaleButton(
                        onTap: onComment,
                        child: _buildActionButton(
                          Icons.chat_bubble_outline,
                          "Ask Question",
                        ),
                      ),
                      const SizedBox(width: 16),
                      ScaleButton(
                        onTap: onShare,
                        child: _buildActionButton(
                          Icons.share_outlined,
                          "Share",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: blackColor5,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: blackColor60),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(fontSize: 11, color: blackColor80)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: blackColor60),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: blackColor60,
          ),
        ),
      ],
    );
  }
}
