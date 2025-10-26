// lib/features/auth/data/models/token_model.dart
import '../../domain/entities/token.dart'; // Đảm bảo import đúng

class TokenModel extends Token {
  // Kế thừa từ class Token của Domain
  // Giả sử class Token có: final String jwt;
  const TokenModel({required String jwt}) : super(jwt: jwt);

  // Hàm "biến hình" từ JSON (ĐÃ SỬA)
  factory TokenModel.fromJson(Map<String, dynamic> json) {
    String? tokenValue;

    // Ưu tiên đọc key "data" (từ backend response)
    if (json.containsKey('data') && json['data'] is String) {
      print("[TokenModel] Parsing from 'data' key.");
      tokenValue = json['data'];
    }
    // Nếu không có "data", thử đọc key "jwt" (từ storage)
    else if (json.containsKey('jwt') && json['jwt'] is String) {
      print("[TokenModel] Parsing from 'jwt' key.");
      tokenValue = json['jwt'];
    }

    // Nếu không tìm thấy token hợp lệ, ném lỗi
    if (tokenValue == null || tokenValue.isEmpty) {
      print("[TokenModel] LỖI: Không tìm thấy key 'data' hoặc 'jwt' hợp lệ.");
      print("JSON nhận được: $json");
      throw ArgumentError(
        'Invalid JSON structure: "data" or "jwt" key is missing, null, or not a String',
      );
    }

    return TokenModel(jwt: tokenValue);
  }

  // Hàm biến hình thành JSON (để lưu trữ) - Giữ nguyên
  Map<String, dynamic> toJson() {
    return {'jwt': jwt}; // Luôn lưu với key 'jwt'
  }
}

// Giả định file lib/features/auth/domain/entities/token.dart của bạn như sau:
// (Bạn không cần tạo file này nếu TokenModel không kế thừa)
/*
import 'package.equatable/equatable.dart';

class Token extends Equatable {
  final String jwt;

  const Token({required this.jwt});

  @override
  List<Object?> get props => [jwt];
}
*/
