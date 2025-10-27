// Dựa theo ảnh swagger image_aca7fd.png
class AccountProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber; // Có thể null
  final String? address; // Có thể null
  final String createDate;
  final String status;
  final String accountRole;
  final String userType;

  AccountProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.address,
    required this.createDate,
    required this.status,
    required this.accountRole,
    required this.userType,
  });
}
