// Lỗi ném ra khi API trả về mã lỗi (404, 500, ...)
class ServerException implements Exception {}

// Lỗi ném ra khi đọc/ghi vào bộ nhớ đệm (cache)
class CacheException implements Exception {}

// Lỗi ném ra khi không có kết nối mạng
class NetworkException implements Exception {}
