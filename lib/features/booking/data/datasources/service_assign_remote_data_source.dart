import '../models/service_assign_model.dart';

abstract class ServiceAssignRemoteDataSource {
  Future<List<ServiceAssignModel>> getByStudioAssignId(String studioAssignId);
}
