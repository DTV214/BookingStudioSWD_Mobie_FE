import '../models/studio_assign_model.dart';

abstract class StudioAssignRemoteDataSource {
  Future<List<StudioAssignModel>> getByBookingId(String bookingId);
}
