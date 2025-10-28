import 'package:flutter/foundation.dart';
import '../../domain/usecases/set_studio_assign_status_usecase.dart';

enum StudioAssignStatusState { idle, loading, success, error }

class StudioAssignStatusProvider extends ChangeNotifier {
  final SetStudioAssignStatusUsecase setStatusUsecase;

  StudioAssignStatusState state = StudioAssignStatusState.idle;
  String message = '';

  StudioAssignStatusProvider({required this.setStatusUsecase});

  Future<void> updateStatus({
    required String assignId,
    required String status,
  }) async {
    state = StudioAssignStatusState.loading;
    message = '';
    notifyListeners();

    try {
      await setStatusUsecase(assignId: assignId, status: status);
      state = StudioAssignStatusState.success;
      message = 'Cập nhật trạng thái thành công';
      notifyListeners();
    } catch (e) {
      state = StudioAssignStatusState.error;
      message = 'Lỗi cập nhật trạng thái: $e';
      notifyListeners();
    }
  }

  void reset() {
    state = StudioAssignStatusState.idle;
    message = '';
    notifyListeners();
  }
}
