import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/payment.dart';
import '../../domain/usecases/get_payments_by_booking_usecase.dart';

enum PaymentState { initial, loading, loaded, error }

class PaymentProvider extends ChangeNotifier {
  final GetPaymentsByBooking getUsecase;

  PaymentProvider({required this.getUsecase});

  PaymentState _state = PaymentState.initial;
  PaymentState get state => _state;

  String _message = '';
  String get message => _message;

  List<Payment> _payments = [];
  List<Payment> get payments => _payments;

  Future<void> fetch(String bookingId) async {
    _state = PaymentState.loading;
    notifyListeners();

    final Either<Failure, List<Payment>> result =
    await getUsecase(GetPaymentsByBookingParams(bookingId));

    result.fold((failure) {
      _message = failure.toString();
      _state = PaymentState.error;
      notifyListeners();
    }, (list) {
      _payments = list;
      _state = PaymentState.loaded;
      notifyListeners();
    });
  }
}
