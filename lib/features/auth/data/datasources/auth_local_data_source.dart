// lib/features/auth/data/datasources/auth_local_data_source.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/token_model.dart';

const CACHED_TOKEN_KEY = 'CACHED_TOKEN';

// "Hợp đồng" cho Local Data Source
abstract class AuthLocalDataSource {
  Future<void> cacheToken(TokenModel tokenToCache);
  Future<TokenModel> getLastToken();
  Future<void> clearToken();
}

// "Triển khai" Hợp đồng
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheToken(TokenModel tokenToCache) {
    try {
      return secureStorage.write(
        key: CACHED_TOKEN_KEY,
        value: json.encode(tokenToCache.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache token');
    }
  }

  @override
  Future<TokenModel> getLastToken() async {
    // <-- 1. THÊM ASYNC
    try {
      final jsonString = await secureStorage.read(key: CACHED_TOKEN_KEY);
      if (jsonString != null) {
        // Chuyển JSON string về lại TokenModel
        return TokenModel.fromJson(
          json.decode(jsonString),
        ); // <-- 2. Bỏ Future.value
      } else {
        throw CacheException('No token cached');
      }
    } catch (e) {
      throw CacheException('Failed to get cached token');
    }
  }

  @override
  Future<void> clearToken() {
    try {
      return secureStorage.delete(key: CACHED_TOKEN_KEY);
    } catch (e) {
      throw CacheException('Failed to clear token');
    }
  }
}
