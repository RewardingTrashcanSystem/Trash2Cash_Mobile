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
    
    // If the path starts with /, combine it directly
    if (relativePath.startsWith('/')) {
      // Remove any trailing slash from baseUrl and combine
      final cleanBaseUrl = baseUrl.endsWith('/') 
          ? baseUrl.substring(0, baseUrl.length - 1) 
          : baseUrl;
      return '$cleanBaseUrl$relativePath';
    }
    
    // For paths without leading slash
    return '$baseUrl/$relativePath';
  }
  
  static const String transferPoints = '/api/points/transfer/';
  static const String checkReceiver = '/api/points/check-receiver/';
  
  // QR Scan endpoint
  static const String qrScan = '/api/points/qr-scan/';
  
  // History endpoints
  static const String history = '/api/points/';
  static const String recentHistory = '/api/points/recent/';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
}