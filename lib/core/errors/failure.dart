// lib/core/error/failure.dart
import 'package:equatable/equatable.dart';

// Lớp cha cho tất cả các Failure
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Lỗi chung từ phía server (API)
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

// Lỗi khi đọc/ghi bộ nhớ cache (secure_storage)
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

// Lỗi từ chính SDK của Google
class GoogleSignInFailure extends Failure {
  const GoogleSignInFailure(String message) : super(message);
}
