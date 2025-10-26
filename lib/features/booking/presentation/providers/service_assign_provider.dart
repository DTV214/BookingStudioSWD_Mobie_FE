import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/service_assign.dart';
import '../../domain/usecases/get_service_assigns_by_studio_assign_usecase.dart';

enum ServiceAssignState { initial, loading, loaded, error }

class ServiceAssignProvider extends ChangeNotifier {
  final GetServiceAssignsByStudioAssign getUsecase;

  ServiceAssignProvider({required this.getUsecase});

  ServiceAssignState _state = ServiceAssignState.initial;
  ServiceAssignState get state => _state;

  List<ServiceAssign> _items = [];
  List<ServiceAssign> get items => _items;

  String _message = '';
  String get message => _message;

  Future<void> fetch(String studioAssignId) async {
    _state = ServiceAssignState.loading;
    notifyListeners();

    final Either<Failure, List<ServiceAssign>> result = await getUsecase(studioAssignId);
    result.fold(
          (failure) {
        _message = 'Đã có lỗi xảy ra';
        _state = ServiceAssignState.error;
        notifyListeners();
      },
          (data) {
        _items = data;
        _state = ServiceAssignState.loaded;
        notifyListeners();
      },
    );
  }
}
