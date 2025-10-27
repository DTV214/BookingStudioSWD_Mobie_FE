// lib/features/profile/data/models/profile_model.dart
import 'package:swd_mobie_flutter/features/account/domain/entities/account_profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    required super.accountRole,
    required super.userType,
    super.avatarUrl,
  });

  // 1. Hàm "biến hình" từ JSON của API GET /api/account/profile
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '', // Dựa trên API GET của bạn
      accountRole: json['accountRole'] ?? '',
      userType: json['userType'] ?? '',
      // API GET của bạn (image_ad7ab0.png) không trả về avatarUrl
      // Chúng ta sẽ tạm để nó là null,
      // API PUT (image_ad7d58.png) cũng không có
      avatarUrl: json['avatarUrl'], // Nếu có thì dùng, không thì null
    );
  }

  // 2. Hàm "biến hình" thành JSON để gửi cho API PUT /api/account
  // Dựa trên Request body (image_ad7d58.png)
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      //
      // ===== LƯU Ý QUAN TRỌNG =====
      // API PUT của bạn yêu cầu tất cả các trường này
      // Staff không được sửa, nên chúng ta phải gửi lại giá trị CŨ
      //
      'role': accountRole,
      'userType': userType,
      //
      // ===== CÁC TRƯỜNG CỐ ĐỊNH =====
      // Dựa theo API PUT, các trường này có vẻ là bắt buộc
      //
      'status': "ACTIVE", // Giả định là luôn ACTIVE khi update
      'personal': true, // Giả định là luôn true
      'locationId': "string", // Tạm thời hardcode,
      // sau này nếu cần, bạn phải lấy từ đâu đó
    };
  }
}
