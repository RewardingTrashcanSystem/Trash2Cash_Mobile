import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trash2cash/core/constants/api_constants.dart';

class ImageHelper {
  // Get full image URL from relative path
  static String getFullImageUrl(String? imagePath) {
    return ApiConstants.getProfileImageUrl(imagePath);
  }

  // Profile image widget with placeholder
  static Widget profileImage({
    required String? imagePath,
    double size = 50,
    bool isCircle = true,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    final fullUrl = getFullImageUrl(imagePath);
    
    if (fullUrl.isEmpty) {
      return _buildPlaceholder(
        size: size,
        isCircle: isCircle,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
      );
    }

    return ClipRRect(
      borderRadius: isCircle 
          ? BorderRadius.circular(size / 2)
          : BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: fullUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(
          size: size,
          isCircle: isCircle,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
          isLoading: true,
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(
          size: size,
          isCircle: isCircle,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
        ),
      ),
    );
  }

  // Network image with loading and error handling
  static Widget networkImage({
    required String? imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    final fullUrl = getFullImageUrl(imagePath);
    
    if (fullUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: Colors.grey[200],
        ),
        child: Icon(Icons.image, color: Colors.grey[400]),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: fullUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Colors.grey[200],
          ),
          child: Icon(Icons.error, color: Colors.red),
        ),
      ),
    );
  }

  // Placeholder widget
  // Placeholder widget - FIXED VERSION
static Widget _buildPlaceholder({
  required double size,
  required bool isCircle,
  Color? backgroundColor,
  Color? iconColor,
  bool isLoading = false,
}) {
  // Define default non-nullable colors
  final Color defaultBackgroundColor = Colors.grey[200]!; // Add ! to make non-nullable
  final Color defaultIconColor = Colors.grey[400]!; // Add ! to make non-nullable
  final Color defaultLoadingColor = Colors.grey[600]!; // Add ! to make non-nullable

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isCircle ? null : BorderRadius.circular(8),
      color: backgroundColor ?? defaultBackgroundColor,
    ),
    child: isLoading
        ? Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              // Use non-nullable colors
              valueColor: AlwaysStoppedAnimation<Color>(
                iconColor ?? defaultLoadingColor,
              ),
            ),
          )
        : Icon(
            Icons.person,
            size: size * 0.5,
            color: iconColor ?? defaultIconColor,
          ),
  );
}
  // Check if path is a network URL
  static bool isNetworkUrl(String? path) {
    if (path == null || path.isEmpty) return false;
    return path.startsWith('http://') || path.startsWith('https://');
  }

  // Check if path is a local asset
  static bool isAssetPath(String? path) {
    if (path == null || path.isEmpty) return false;
    return path.startsWith('assets/');
  }

  // Check if path is a local file
  static bool isLocalFile(String? path) {
    if (path == null || path.isEmpty) return false;
    return path.startsWith('/') && !path.startsWith('http');
  }
}