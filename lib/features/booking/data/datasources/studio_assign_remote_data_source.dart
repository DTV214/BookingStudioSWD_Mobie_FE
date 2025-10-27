import '../models/studio_assign_model.dart';

abstract class StudioAssignRemoteDataSource {
  Future<List<StudioAssignModel>> getByBookingId(String bookingId);

  Future<void> setStatus({
    required String assignId,
    required String status,
  });
}
