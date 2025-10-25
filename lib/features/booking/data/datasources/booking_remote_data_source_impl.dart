import 'dart:convert';
import 'dart:io'; // Thêm import này để bắt lỗi mạng
import 'package:http/http.dart' as http;
import '../../../../core/error/exception.dart';
import '../models/booking_model.dart';
import 'booking_remote_data_source.dart';

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final http.Client client;

  // Lấy URL API từ ảnh Swagger của bạn
  final String _baseUrl = "https://bookingstudioswd-be.onrender.com";

  BookingRemoteDataSourceImpl({required this.client});

  @override
  Future<List<BookingModel>> getBookings() async {
    final url = Uri.parse('$_baseUrl/api/bookings');
    print('[BookingDataSource] Đang gọi API: $url'); // LOG 1: Kiểm tra URL

    try {
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print(
        '[BookingDataSource] API Response Status Code: ${response.statusCode}',
      ); // LOG 2: Kiểm tra status

      if (response.statusCode == 200) {
        print(
          '[BookingDataSource] API Response Body (Success): ${response.body}',
        ); // LOG 3: Xem data thô

        try {
          // 1. Decode toàn bộ body response
          final Map<String, dynamic> jsonResponse =
              json.decode(response.body) as Map<String, dynamic>;
          print('[BookingDataSource] Đã decode JSON response.'); // LOG 4

          // 2. Lấy list 'data' từ JSON
          // KIỂM TRA KEY 'data' TỒN TẠI
          if (jsonResponse['data'] == null) {
            print(
              '[BookingDataSource] LỖI: Key "data" không tồn tại trong JSON.',
            ); // LOG 5
            throw ServerException();
          }

          final List<dynamic> dataList = jsonResponse['data'] as List<dynamic>;
          print(
            '[BookingDataSource] Đã tìm thấy ${dataList.length} items trong "data".',
          ); // LOG 6

          // 3. Map mỗi item trong list thành một BookingModel
          final List<BookingModel> bookings = dataList
              .map(
                (item) => BookingModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();

          print(
            '[BookingDataSource] Đã parse thành công ${bookings.length} BookingModels.',
          ); // LOG 7
          return bookings;
        } catch (e) {
          // Lỗi nếu JSON trả về không đúng cấu trúc
          print('[BookingDataSource] LỖI PARSE JSON: $e'); // LOG 8
          print('[BookingDataSource] JSON bị lỗi: ${response.body}'); // LOG 9
          throw ServerException();
        }
      } else {
        // Ném lỗi server nếu status code không phải 200
        print(
          '[BookingDataSource] LỖI SERVER: Status code là ${response.statusCode}',
        ); // LOG 10
        print(
          '[BookingDataSource] API Response Body (Error): ${response.body}',
        ); // LOG 11
        throw ServerException();
      }
    } on SocketException catch (e) {
      // Bắt lỗi mạng (không có kết nối)
      print('[BookingDataSource] LỖI MẠNG (SocketException): $e'); // LOG 12
      throw NetworkException(); // Ném lỗi Mạng để Repository bắt
    } on http.ClientException catch (e) {
      // Bắt các lỗi khác của http client (ví dụ: host lookup failed)
      print('[BookingDataSource] LỖI HTTP CLIENT: $e'); // LOG 13
      throw NetworkException();
    } catch (e) {
      // Bắt tất cả các lỗi khác không lường trước được
      print('[BookingDataSource] LỖI KHÔNG XÁC ĐỊNH: $e'); // LOG 14
      throw ServerException();
    }
  }
}
