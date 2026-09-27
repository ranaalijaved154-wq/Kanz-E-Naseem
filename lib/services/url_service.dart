import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

class UrlService {
  /// Opens the official YouTube channel in the YouTube app or browser
  static Future<bool> openYouTubeChannel(BuildContext context) async {
    return launchWebUrl(context, AppConstants.youtubeChannelUrl);
  }

  /// General URL launcher with user-friendly error feedback
  static Future<bool> launchWebUrl(BuildContext context, String urlString) async {
    try {
      final uri = Uri.parse(urlString.trim());
      final bool canLaunch = await canLaunchUrl(uri);
      
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && !canLaunch && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'لنک کھولنے کے لیے براؤزر یا یوٹیوب ایپ دستیاب نہیں ہے',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return launched;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خرابی: $e',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }
}
