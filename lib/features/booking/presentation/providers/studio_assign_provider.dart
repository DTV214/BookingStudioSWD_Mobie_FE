import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart'; // sửa path nếu base nằm nơi khác
import '../../domain/entities/studio_assign.dart';
import '../../domain/usecases/get_studio_assigns_by_booking_usecase.dart';

enum StudioAssignState { initial, loading, loaded, error }

class StudioAssignProvider extends ChangeNotifier {
  final GetStudioAssignsByBooking getUsecase;

  StudioAssignProvider({required this.getUsecase});

  StudioAssignState _state = StudioAssignState.initial;
  StudioAssignState get state => _state;

  List<StudioAssign> _items = [];
  List<StudioAssign> get items => _items;

  String _message = '';
  String get message => _message;

  Future<void> fetch(String bookingId) async {
    _state = StudioAssignState.loading;
    notifyListeners();

    final result = await getUsecase(bookingId);
    result.fold(
          (failure) {
        _message = "Lỗi: Không thể tải danh sách booking.";
        _state = StudioAssignState.error;
        notifyListeners();
      },
          (data) {
        _items = data;
        _state = StudioAssignState.loaded;
        notifyListeners();
      },
    );
  }
}
