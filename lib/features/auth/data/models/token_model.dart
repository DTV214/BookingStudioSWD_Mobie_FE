// lib/features/auth/data/models/token_model.dart
import '../../domain/entities/token.dart';

class TokenModel extends Token {
  // Kế thừa từ class Token của Domain
  const TokenModel({required String jwt}) : super(jwt: jwt);

  // Hàm "biến hình" từ JSON
  // API của bạn trả về: { "code": 100, "message": "...", "data": "JWT_STRING" }
  factory TokenModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('data') && json['data'] != null) {
      return TokenModel(jwt: json['data']);
    } else {
      // Ném lỗi nếu key 'data' không có hoặc null
      throw ArgumentError(
        'Invalid JSON structure: "data" key is missing or null',
      );
    }
  }

  // Hàm biến hình thành JSON (để lưu trữ)
  Map<String, dynamic> toJson() {
    return {'jwt': jwt};
  }
}
