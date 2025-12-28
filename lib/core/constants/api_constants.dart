class ApiConstants {
  static const String baseUrl = 'https://trash2cash-backend-hclt.onrender.com';

  // Auth Endpoints (from your Django API)
  static const String checkRegistration = '/api/auth/check-registration/';
  static const String register = '/api/auth/register/';
  static const String login = '/api/auth/login/';
  static const String logout = '/api/auth/logout/';
  static const String profile = '/api/auth/profile/';
  
  // Image Helper Methods
  static String getProfileImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    
    // If image already has full URL, return it
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Handle different path formats
    String cleanPath;
    if (imagePath.startsWith('/media/')) {
      // Remove leading slash to avoid double slash
      cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    } else if (imagePath.startsWith('media/')) {
      cleanPath = imagePath;
    } else {
      // Assume it's in media/profiles
      cleanPath = imagePath.startsWith('/') 
          ? 'media/profiles${imagePath}'
          : 'media/profiles/$imagePath';
    }
    
    return '$baseUrl/$cleanPath';
  }
  
  static String getImageFullUrl(String relativePath) {
    // Handle null or empty paths
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }
    
    // Check if it's already a full URL
    if (Uri.parse(relativePath).isAbsolute) {
      return relativePath;
    }
    
    // Clean the path and combine with base URL
    final cleanPath = relativePath.startsWith('/') 
        ? relativePath.substring(1) 
        : relativePath;
    
    return '$baseUrl/$cleanPath';
  }

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
}