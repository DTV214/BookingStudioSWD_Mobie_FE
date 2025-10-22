import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async'; // Thêm thư viện timeout
import '../models/studio_model.dart';

// Định nghĩa 1 abstract class để dễ dàng test (mock) sau này
abstract class StudioRemoteDataSource {
  Future<List<StudioModel>> getStudios();

  // --- THÊM MỚI HÀM UPDATE ---
  Future<void> updateStudio(StudioModel studio);
  // --------------------------
}

// Class triển khai
class StudioRemoteDataSourceImpl implements StudioRemoteDataSource {
  final http.Client client;
  // URL API từ file Swagger của bạn (Bỏ dấu / ở cuối)
  final String _baseUrl = "https://bookingstudioswd-be.onrender.com";

  StudioRemoteDataSourceImpl({required this.client});

  @override
  Future<List<StudioModel>> getStudios() async {
    // 2. Tạo URL với tham số mới
    final Uri uri = Uri.parse("$_baseUrl/api/studios");

    // 3. IN RA URL CUỐI CÙNG ĐỂ KIỂM TRA
    print('--- ĐANG GỌI API (GET) ---');
    print('URL: ${uri.toString()}');
    print('---------------------');

    http.Response response; // Khai báo response ở đây

    try {
      // 2. Gọi API với thời gian chờ (timeout) 10 giây
      // Dịch vụ OnRender miễn phí có thể "ngủ" và cần thời gian khởi động
      response = await client
          .get(
            uri,
            headers: {
              'Accept': '*/*', // Giống với SWAGGER
              // 4. Thêm User-Agent giả lập trình duyệt
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36',
            },
          )
          .timeout(const Duration(seconds: 15)); // Tăng timeout lên 15 giây
    } on TimeoutException catch (e) {
      // Bắt lỗi nếu API quá chậm (quá 15 giây)
      print('--- LỖI API (GET): TIMEOUT ---');
      print(e.toString());
      throw Exception(
        'API call (GET) timed out (15s). Server might be sleeping.',
      );
    } catch (e) {
      // Bắt các lỗi khác (ví dụ: không có mạng)
      print('--- LỖI API (GET): NETWORK/CLIENT ERROR ---');
      print(e.toString());
      throw Exception('Failed to connect to API (GET): $e');
    }

    // 3. Kiểm tra kết quả
    if (response.statusCode == 200) {
      // 4. Decode JSON
      // API của bạn trả về { "code": 200, "message": "...", "data": [...] }
      final Map<String, dynamic> body = json.decode(response.body);

      // Lấy danh sách "data"
      final List<dynamic> dataList = body['data'] as List;

      // 5. Chuyển list JSON thành List<StudioModel>
      return dataList
          .map((item) => StudioModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      // 6. NẾU THẤT BẠI, IN RA CHI TIẾT LỖI
      print('--- LỖI API (GET): STATUS CODE KHÔNG PHẢI 200 ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('-------------------------------------------');

      // Ném ra một lỗi rõ ràng hơn
      throw Exception(
        'Failed to load studios. Status Code: ${response.statusCode}',
      );
    }
  }

  // --- THÊM MỚI: TRIỂN KHAI HÀM UPDATE STUDIO ---
  @override
  Future<void> updateStudio(StudioModel studio) async {
    // 1. Tạo URL động với ID
    final Uri uri = Uri.parse("$_baseUrl/api/studios/${studio.id}");

    // 2. In log để debug
    print('--- ĐANG GỌI API (PUT) ---');
    print('URL: ${uri.toString()}');
    // Mã hóa body sang JSON để in
    final String requestBody = json.encode(studio.toJson());
    print('Body: $requestBody');
    print('-------------------------');

    http.Response response;
    try {
      // 3. Gọi client.put
      response = await client
          .put(
            uri,
            headers: {
              // Header này RẤT QUAN TRỌNG cho các request PUT/POST
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': '*/*', // Giữ nguyên từ Swagger/GET
              'User-Agent': // Giữ nguyên User-Agent
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36',
            },
            body: requestBody, // Gửi body đã được mã hóa
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException catch (e) {
      print('--- LỖI API (PUT): TIMEOUT ---');
      print(e.toString());
      throw Exception('API call (PUT) timed out (15s).');
    } catch (e) {
      print('--- LỖI API (PUT): NETWORK/CLIENT ERROR ---');
      print(e.toString());
      throw Exception('Failed to connect to API (PUT): $e');
    }

    // 4. Kiểm tra kết quả
    if (response.statusCode == 200) {
      // API của bạn trả về 200 khi thành công
      print('Update studio successfully!');
      // Không cần trả về gì cả (void)
    } else {
      // Nếu thất bại, ném lỗi
      print('--- LỖI API (PUT): STATUS CODE KHÔNG PHẢI 200 ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('-------------------------------------------');
      throw Exception(
        'Failed to update studio. Status Code: ${response.statusCode}',
      );
    }
  }
}
