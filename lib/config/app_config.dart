class AppConfig {
  // API Base URLs
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.219.101:8000',
  );

  // API Endpoints
  static const String socialGoogleEndpoint = '/api/v1/users/social/google';
  static const String socialKakaoEndpoint = '/api/v1/users/social/kakao';
  static const String usersEndpoint = '/api/v1/users/';
  static const String usersMeEndpoint = '/api/v1/users/me';
  static const String refreshTokenEndpoint = '/api/v1/users/refresh-token';
  static const String celebEndpoint = '/api/v1/celeb/';
  static const String hobbyEndpoint = '/api/v1/users/hobby/';

  // CloudFront
  static const String cloudFrontDomain = String.fromEnvironment(
    'CLOUDFRONT_DOMAIN',
    defaultValue: 'https://d1v09q065yb59g.cloudfront.net',
  );

  static const String s3Domain = String.fromEnvironment(
    'S3_DOMAIN',
    defaultValue: 'https://celebvoice-storage.s3.ap-northeast-2.amazonaws.com',
  );

  // Colors
  static const int primaryColorValue = 0xff9e9ef4;
  static const int backgroundColorValue = 0xffEFF0F4;
  static const int messageCardColorValue = 0xFF6C5CE7;
  static const int lightBackgroundColorValue = 0xFFF8F9FA;

  // Sizes
  static const double cardBorderRadius = 12.0;
  static const double pageViewHeightFactor = 0.78;
  static const double messageCardHeight = 120.0;
  static const double messageCardWidth = 200.0;

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String tokenTypeKey = 'token_type';
  static const String refreshTokenKey = 'refresh_token';
  static const String expiresInKey = 'expires_in';

  // HTTP Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'User-Agent': 'Mozilla/5.0 (compatible; Flutter app)',
  };

  // Debug Settings
  static const bool enableDebugLogs = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGS',
    defaultValue: true,
  );

  static String getImageUrl(String s3Url) {
    if (s3Url.contains('s3.ap-northeast-2.amazonaws.com')) {
      // S3 URL을 CloudFront URL로 변환
      return s3Url.replaceAll(
        'https://celebvoice-storage.s3.ap-northeast-2.amazonaws.com',
        cloudFrontDomain,
      );
    }
    return s3Url;
  }
}
