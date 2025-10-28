import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/addition_time_result.dart';
import '../../domain/usecases/add_studio_assign_addition_time_usecase.dart';

enum AdditionTimeState { initial, loading, success, error }

class AdditionTimeProvider extends ChangeNotifier {
  final AddStudioAssignAdditionTimeUsecase usecase;

  AdditionTimeProvider({required this.usecase});

  AdditionTimeState _state = AdditionTimeState.initial;
  AdditionTimeState get state => _state;

  String _message = '';
  String get message => _message;

  AdditionTimeResult? _result;
  AdditionTimeResult? get result => _result;

  Future<void> add({
    required String assignId,
    required int additionMinutes,
  }) async {
    _state = AdditionTimeState.loading;
    _message = '';
    _result = null;
    notifyListeners();

    final Either<Failure, AdditionTimeResult> res = await usecase(
      assignId: assignId,
      additionMinutes: additionMinutes,
    );

    res.fold((fail) {
      _state = AdditionTimeState.error;
      _message = _mapFailure(fail);
      notifyListeners();
    }, (data) {
      _state = AdditionTimeState.success;
      _result = data;
      notifyListeners();
    });
  }

  String _mapFailure(Failure f) {
    if (f is NetworkFailure) return 'Lỗi mạng. Vui lòng thử lại.';
    if (f is ServerFailure) return 'Lỗi máy chủ. Vui lòng thử lại.';
    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}
