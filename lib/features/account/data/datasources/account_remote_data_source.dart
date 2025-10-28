// lib/features/profile/data/datasources/profile_remote_data_source.dart
import 'dart:convert';
import 'package:swd_mobie_flutter/features/account/data/models/account_profile_model.dart';

import 'package:http/http.dart' as http;
import '../../../../core/errors/exceptions.dart';
// ⭐ QUAN TRỌNG: Import local data source của AUTH để lấy token
import '../../../auth/data/datasources/auth_local_data_source.dart';

// ===== ĐỊNH NGHĨA ENDPOINTS =====
// ⚠️ THAY THẾ 'https://your-backend-url.com' bằng URL backend Spring Boot của bạn
const String BASE_URL =
    "https://bookingstudioswd-be.onrender.com"; // API từ ảnh của bạn
const String PROFILE_ENDPOINT =
    "/api/account/profile"; // API GET (từ ảnh image_ad7ab0.png)
const String UPDATE_ENDPOINT =
    "/api/account"; // API PUT (từ ảnh image_ad7d58.png)
// ===================================

// "Hợp đồng"
abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<void> updateProfile(ProfileModel profileToUpdate);
}

// "Triển khai" hợp đồng
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource; // Để lấy token

  ProfileRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  // === Hàm nội bộ tiện ích để lấy Headers kèm Token ===
  Future<Map<String, String>> _getHeaders() async {
    // 1. Lấy token từ storage
    final tokenModel = await authLocalDataSource.getLastToken();
    if (tokenModel == null) {
      print(
        "[ProfileRemoteDataSource] Lỗi: Không tìm thấy token. Người dùng chưa đăng nhập?",
      );
      throw CacheException('No cached token found'); // Ném lỗi
    }

    // 2. Tạo headers
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${tokenModel.jwt}', // Gắn token vào đây
    };
  }

  // === 1. HÀM GỌI API GET PROFILE ===
  @override
  Future<ProfileModel> getProfile() async {
    print("[ProfileRemoteDataSource] Đang gọi GET $PROFILE_ENDPOINT...");
    try {
      final headers = await _getHeaders(); // Lấy headers kèm token
      final response = await client.get(
        Uri.parse('$BASE_URL$PROFILE_ENDPOINT'),
        headers: headers,
      );

      print(
        "[ProfileRemoteDataSource] GET response status: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        // API của bạn trả về { "code": 200, "message": "...", "data": {...} }
        // Chúng ta cần parse "data"
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        final data = responseBody['data'];
        print("[ProfileRemoteDataSource] Lấy profile thành công.");
        return ProfileModel.fromJson(data);
      } else {
        print("[ProfileRemoteDataSource] Lỗi Server: ${response.body}");
        throw ServerException('Failed to get profile');
      }
    } on CacheException catch (e) {
      // Bắt lỗi từ _getHeaders()
      rethrow; // Ném lại lỗi CacheException
    } catch (e) {
      print("[ProfileRemoteDataSource] Lỗi không xác định: $e");
      throw ServerException('An unexpected error occurred');
    }
  }

  // === 2. HÀM GỌI API UPDATE PROFILE ===
  @override
  Future<void> updateProfile(ProfileModel profileToUpdate) async {
    print("[ProfileRemoteDataSource] Đang gọi PUT $UPDATE_ENDPOINT...");
    try {
      final headers = await _getHeaders(); // Lấy headers kèm token

      // Dùng hàm `toJsonForUpdate` từ ProfileModel
      final body = json.encode(profileToUpdate.toJsonForUpdate());
      print("[ProfileRemoteDataSource] Gửi đi body: $body");

      final response = await client.put(
        Uri.parse('$BASE_URL$UPDATE_ENDPOINT'),
        headers: headers,
        body: body,
      );

      print(
        "[ProfileRemoteDataSource] PUT response status: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        // API PUT (image_ad7d58.png) trả về code 200 là OK
        print("[ProfileRemoteDataSource] Cập nhật profile thành công.");
        return; // Không cần trả về gì cả (Future<void>)
      } else {
        print("[ProfileRemoteDataSource] Lỗi Server: ${response.body}");
        throw ServerException('Failed to update profile');
      }
    } on CacheException catch (e) {
      rethrow;
    } catch (e) {
      print("[ProfileRemoteDataSource] Lỗi không xác định: $e");
      throw ServerException('An unexpected error occurred');
    }
  }
}
