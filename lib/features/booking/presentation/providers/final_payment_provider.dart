import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/final_payment.dart';
import '../../domain/usecases/create_final_payment_usecase.dart';

enum FinalPaymentState { initial, loading, success, error }

class FinalPaymentProvider extends ChangeNotifier {
  final CreateFinalPaymentUsecase usecase;

  FinalPaymentProvider({required this.usecase});

  FinalPaymentState _state = FinalPaymentState.initial;
  FinalPaymentState get state => _state;

  String _message = '';
  String get message => _message;

  FinalPayment? _finalPayment;
  FinalPayment? get finalPayment => _finalPayment;

  Future<void> create({
    required String bookingId,
    required String paymentMethod, // 'VNPAY' | 'MOMO' | 'CASH'
  }) async {
    _state = FinalPaymentState.loading;
    _message = '';
    _finalPayment = null;
    notifyListeners();

    final Either<Failure, FinalPayment> result = await usecase(
      bookingId: bookingId,
      paymentMethod: paymentMethod,
    );

    result.fold((fail) {
      _state = FinalPaymentState.error;
      _message = _mapFailure(fail);
      notifyListeners();
    }, (data) {
      _state = FinalPaymentState.success;
      _finalPayment = data;
      notifyListeners();
    });
  }

  String _mapFailure(Failure f) {
    if (f is NetworkFailure) return 'Lỗi mạng. Vui lòng thử lại.';
    if (f is ServerFailure) return 'Lỗi máy chủ. Vui lòng thử lại.';
    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}
