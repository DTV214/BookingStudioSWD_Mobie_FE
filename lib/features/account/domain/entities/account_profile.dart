// lib/features/profile/domain/entities/profile.dart
import 'package:equatable/equatable.dart';

// Equatable giúp chúng ta so sánh 2 đối tượng Profile
// mà không cần so sánh từng thuộc tính thủ công
class Profile extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String accountRole; // STAFF, ADMIN, etc.
  final String userType; // PERSONAL, etc.
  final String? avatarUrl; // Có thể null

  const Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.accountRole,
    required this.userType,
    this.avatarUrl,
  });

  // Đây là phần của Equatable,
  // nó sẽ so sánh các đối tượng dựa trên các giá trị này
  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phoneNumber,
    accountRole,
    userType,
    avatarUrl,
  ];
}
