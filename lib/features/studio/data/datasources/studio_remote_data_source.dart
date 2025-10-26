import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swd_mobie_flutter/features/studio/domain/entities/studio.dart';
import 'dart:async';
import '../models/studio_model.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
// ** QUAN TRỌNG: Đảm bảo đường dẫn này đúng tới file TokenModel của bạn **
import '../../../auth/data/models/token_model.dart'; // Hoặc entities/token.dart

abstract class StudioRemoteDataSource {
  Future<List<StudioModel>> getStudios();
  Future<void> updateStudio(StudioModel studio);
  Future<void> patchStudioStatus(String studioId, StudioStatus status);
}

class StudioRemoteDataSourceImpl implements StudioRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String _baseUrl = "https://bookingstudioswd-be.onrender.com";

  StudioRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  // --- HÀM HELPER LẤY HEADER (ĐÃ SỬA) ---
  Future<Map<String, String>> _getAuthHeaders() async {
    print("[StudioDataSource] Đang gọi _getAuthHeaders...");
    try {
      // 1. Gọi hàm getLastToken() để lấy TokenModel? (có thể null)
      final TokenModel? tokenModel = await authLocalDataSource.getLastToken();

      // 2. Xử lý trường hợp null
      if (tokenModel == null) {
        print(
          "[StudioDataSource] Lỗi: getLastToken() trả về null (chưa đăng nhập hoặc lỗi đọc storage).",
        );
        // Ném lỗi để dừng việc gọi API
        throw Exception('Bạn chưa đăng nhập hoặc có lỗi đọc token.');
      }
      print("[StudioDataSource] Đã lấy được TokenModel.");

      // 3. Truy cập đúng thuộc tính đã thống nhất ('jwt')
      final String? tokenString = tokenModel.jwt; // <-- SỬ DỤNG .jwt

      if (tokenString == null || tokenString.isEmpty) {
        print(
          "[StudioDataSource] Lỗi: Chuỗi token ('jwt') trong TokenModel rỗng hoặc null.",
        );
        throw Exception('Lỗi: Token không hợp lệ.');
      }

      print(
        "[StudioDataSource] ✅ Lấy được token: Bearer ${tokenString.substring(0, 10)}...",
      );

      return {
        'Accept': '*/*',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36',
        'Authorization': 'Bearer $tokenString',
      };
      // Bắt Exception chung (bao gồm cả lỗi ném ra do null)
    } catch (e, stacktrace) {
      print("[StudioDataSource] Lỗi trong _getAuthHeaders: $e");
      print(stacktrace);
      // Ném lại lỗi để các hàm gọi API xử lý
      rethrow;
    }
  }

  // --- HÀM HELPER CHO PUT/POST/PATCH (Giữ nguyên) ---
  Future<Map<String, String>> _getAuthHeadersWithContent() async {
    final headers = await _getAuthHeaders();
    headers['Content-Type'] = 'application/json; charset=UTF-8';
    return headers;
  }

  // --- CÁC HÀM API (GET, PUT, PATCH) (Giữ nguyên) ---
  // Chúng không cần thay đổi vì lỗi đã được xử lý trong _getAuthHeaders
  @override
  Future<List<StudioModel>> getStudios() async {
    // ... (Code gọi _getAuthHeaders() và client.get() giữ nguyên) ...
    final Uri uri = Uri.parse("$_baseUrl/api/studios/staff");
    print('[StudioDataSource] --- ĐANG GỌI API (GET) /api/studios/staff ---');
    http.Response response;
    try {
      final headers = await _getAuthHeaders(); // Lấy header mới
      response = await client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      print('[StudioDataSource] --- LỖI API (GET): ${e.toString()} ---');
      rethrow;
    }
    // ... (Code xử lý response giữ nguyên) ...
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      if (body.containsKey('data') && body['data'] is List) {
        final List<dynamic> dataList = body['data'] as List;
        print(
          "[StudioDataSource] GET thành công, nhận được ${dataList.length} studio.",
        );
        return dataList
            .map((item) => StudioModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print(
          '[StudioDataSource] --- LỖI API (GET): Cấu trúc JSON không đúng ---',
        );
        print('Response Body: ${response.body}');
        throw Exception(
          'API response format is incorrect (missing "data" list)',
        );
      }
    } else {
      print(
        '[StudioDataSource] --- LỖI API (GET): STATUS CODE ${response.statusCode} ---',
      );
      print('Response Body: ${response.body}');
      throw Exception(
        'Failed to load studios. Status Code: ${response.statusCode}',
      );
    }
  }

  @override
  Future<void> updateStudio(StudioModel studio) async {
    // ... (Code gọi _getAuthHeadersWithContent() và client.put() giữ nguyên) ...
    final Uri uri = Uri.parse("$_baseUrl/api/studios/status/${studio.id}");
    final String requestBody = json.encode(studio.toJson());
    print('[StudioDataSource] --- ĐANG GỌI API (PUT) ---');
    http.Response response;
    try {
      final headers = await _getAuthHeadersWithContent(); // Lấy header mới
      response = await client
          .put(uri, headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      print('[StudioDataSource] --- LỖI API (PUT): ${e.toString()} ---');
      rethrow; // Ném lại lỗi gốc
    }
    // ... (Code xử lý response giữ nguyên) ...
    if (response.statusCode == 200) {
      print('[StudioDataSource] Update studio successfully!');
    } else {
      print(
        '[StudioDataSource] --- LỖI API (PUT): STATUS CODE ${response.statusCode} ---',
      );
      print('Response Body: ${response.body}');
      throw Exception(
        'Failed to update studio. Status Code: ${response.statusCode}',
      );
    }
  }

  @override
  Future<void> patchStudioStatus(String studioId, StudioStatus status) async {
    final Uri uri = Uri.parse("$_baseUrl/api/studios/status/$studioId");

    // 2. Chuyển đổi Enum thành String theo yêu cầu của Backend
    String statusString;
    switch (status) {
      case StudioStatus.available:
        statusString = "AVAILABLE";
        break;
      case StudioStatus.maintenance:
        statusString = "MAINTENANCE";
        break;
      case StudioStatus.deleted:
        statusString = "DELETED";
        break;

      default:
        print("Lỗi logic: Cố gắng PATCH trạng thái không hợp lệ: $status");
        throw Exception("Trạng thái không hợp lệ để cập nhật: $status");
    }

    // Body chỉ chứa status dạng String
    final String requestBody = json.encode({"status": statusString});

    print('[StudioDataSource] --- ĐANG GỌI API (PATCH) ---');
    print('URL: ${uri.toString()}');
    print('Body: $requestBody');

    http.Response response;
    try {
      final headers = await _getAuthHeadersWithContent();
      response = await client
          .patch(uri, headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      print('[StudioDataSource] --- LỖI API (PATCH): ${e.toString()} ---');
      rethrow;
    }

    if (response.statusCode == 200) {
      print('[StudioDataSource] Patch studio status successfully!');
    } else {
      print(
        '[StudioDataSource] --- LỖI API (PATCH): STATUS CODE ${response.statusCode} ---',
      );
      print('Response Body: ${response.body}');
      throw Exception(
        'Failed to patch studio status. Status Code: ${response.statusCode}',
      );
    }
  }
}
