import '../../domain/entities/account_profile.dart';

class AccountProfileModel extends AccountProfile {
  AccountProfileModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phoneNumber,
    super.address,
    required super.createDate,
    required super.status,
    required super.accountRole,
    required super.userType,
  });

  // Hàm "biến hình" từ JSON
  factory AccountProfileModel.fromJson(Map<String, dynamic> json) {
    // API của bạn trả về data nằm trong key "data"
    final data = json['data'];

    return AccountProfileModel(
      id: data['id'],
      email: data['email'],
      fullName: data['fullName'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      createDate: data['createDate'],
      status: data['status'],
      accountRole: data['accountRole'],
      userType: data['userType'],
    );
  }
}
