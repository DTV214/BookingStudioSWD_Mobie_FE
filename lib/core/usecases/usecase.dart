// lib/core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failure.dart';

// Base class cho tất cả Usecase
// [Type] là kiểu dữ liệu trả về (vd: List<Booking>)
// [Params] là tham số đầu vào (vd: String id, hoặc NoParams)
abstract class UseCase<Type, Params> {
  // Tất cả usecase đều có thể gọi được như một hàm
  Future<Either<Failure, Type>> call(Params params);
}

// Dùng khi Usecase không cần tham số đầu vào
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
