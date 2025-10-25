// lib/core/error/exceptions.dart

// Lỗi khi gọi API
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

// Lỗi khi đọc/ghi cache
class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

// Lỗi khi SDK google_sign_in thất bại
class GoogleSignInException implements Exception {
  final String message;
  GoogleSignInException(this.message);
}
