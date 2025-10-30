// lib/features/auth/data/datasources/auth_local_data_source.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/token_model.dart';

const CACHED_TOKEN_KEY = 'CACHED_TOKEN';

// "Hợp đồng" cho Local Data Source
abstract class AuthLocalDataSource {
  Future<void> cacheToken(TokenModel tokenToCache);

  Future<TokenModel?> getLastToken();

  Future<void> clearToken();

  Future<String?> getAccessToken();
}

// "Triển khai" Hợp đồng
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  // @override
  // Future<void> cacheToken(TokenModel tokenToCache) {
  //   try {
  //     return secureStorage.write(
  //       key: CACHED_TOKEN_KEY,
  //       value: json.encode(tokenToCache.toJson()),
  //     );
  //   } catch (e) {
  //     print("[AuthLocalDataSource] LỖI cacheToken: $e");
  //     throw CacheException('Failed to cache token');
  //   }
  // }
  @override
  Future<void> cacheToken(TokenModel tokenToCache) async {
    try {
      // Gọi toJson() của TokenModel (giả sử nó trả về {"jwt": ...})
      final jsonString = json.encode(tokenToCache.toJson());
      print(
        "[AuthLocalDataSource] Đang cache token JSON: ${jsonString.substring(0, 20)}...",
      );
      await secureStorage.write(key: CACHED_TOKEN_KEY, value: jsonString);
      print("[AuthLocalDataSource] Cache token thành công.");
    } catch (e) {
      print("[AuthLocalDataSource] LỖI cacheToken: $e");
    }
  }

  @override
  Future<TokenModel?> getLastToken() async {
    // --- SỬA LẠI KIỂU TRẢ VỀ ---
    print("[AuthLocalDataSource] Đang gọi getLastToken...");
    String? jsonString;
    try {
      print("[AuthLocalDataSource] Đang đọc từ secureStorage...");
      jsonString = await secureStorage.read(key: CACHED_TOKEN_KEY);
      print(
        "[AuthLocalDataSource] Đọc xong. jsonString is null? ${jsonString == null}",
      );

      if (jsonString != null) {
        print("[AuthLocalDataSource] Đang parse JSON...");
        // Gọi fromJson() của TokenModel (cần sửa để đọc được {"jwt":...})
        final tokenModel = TokenModel.fromJson(json.decode(jsonString));
        print("[AuthLocalDataSource] Parse JSON thành công.");
        return tokenModel;
      } else {
        print("[AuthLocalDataSource] Không tìm thấy token đã cache.");
        return null; // Trả về null nếu không có token
      }
    } catch (e, stacktrace) {
      print("[AuthLocalDataSource] LỖI getLastToken:");
      print("Lỗi: $e");
      print("JSON String đọc được (nếu có): $jsonString");
      print("Stacktrace: $stacktrace");
      return null; // Trả về null nếu có lỗi đọc/parse
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      print("[AuthLocalDataSource] Đang xóa token...");
      await secureStorage.delete(key: CACHED_TOKEN_KEY);
      print("[AuthLocalDataSource] Xóa token thành công.");
    } catch (e) {
      print("[AuthLocalDataSource] LỖI clearToken: $e");
    }
  }

  @override
  Future<String?> getAccessToken() async {
    final tokenModel = await getLastToken();
    return tokenModel?.jwt;
  }
}
