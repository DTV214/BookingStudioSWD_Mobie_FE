// lib/features/auth/domain/entities/token.dart
import 'package:equatable/equatable.dart';

// Dùng class để dễ mở rộng sau này (vd: thêm refresh token)
class Token extends Equatable {
  final String jwt;

  const Token({required this.jwt});

  @override
  List<Object> get props => [jwt];
}
