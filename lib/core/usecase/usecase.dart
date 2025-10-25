// lib/core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:swd_mobie_flutter/core/errors/failure.dart';


// Giao diện chung cho 1 Usecase
// Type: Kiểu dữ liệu trả về khi thành công (VD: Token)
// Params: Tham số đầu vào (VD: email, password)
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Dùng khi Usecase không cần tham số đầu vào
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
