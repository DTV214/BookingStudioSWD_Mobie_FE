import 'package:equatable/equatable.dart';

// Một lớp trừu tượng (abstract) cho tất cả các Lỗi (Failure)
// Sạch sẽ hơn là ném (throw) Exceptions
abstract class Failure extends Equatable {
  final List properties;
  const Failure([this.properties = const <dynamic>[]]);

  @override
  List<Object> get props => [properties];
}

// Các lỗi cụ thể
// Lỗi từ Server (API trả về 404, 500, etc.)
class ServerFailure extends Failure {}

// Lỗi không có kết nối mạng
class NetworkFailure extends Failure {}

// Lỗi từ bộ nhớ đệm (cache)
class CacheFailure extends Failure {}
