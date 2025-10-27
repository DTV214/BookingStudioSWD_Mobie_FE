import '../models/studio_assign_model.dart';
import '../models/addition_time_result_model.dart';

abstract class StudioAssignRemoteDataSource {
  Future<List<StudioAssignModel>> getByBookingId(String bookingId);

  Future<void> setStatus({
    required String assignId,
    required String status,
  });

  Future<AdditionTimeResultModel> addAdditionTime({
    required String assignId,
    required int additionMinutes,
  });
}
