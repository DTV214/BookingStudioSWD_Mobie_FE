import '../../domain/entities/studio.dart';
import '../../domain/repositories/studio_repository.dart';
import '../datasources/studio_remote_data_source.dart';
import '../models/studio_model.dart';

class StudioRepositoryImpl implements StudioRepository {
  final StudioRemoteDataSource remoteDataSource;

  StudioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Studio>> getStudios() async {
    try {
      final List<Studio> remoteStudios = await remoteDataSource.getStudios();
      return remoteStudios;
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to fetch data. Check your connection.');
    }
  }

  @override
  Future<void> updateStudio(Studio studio) async {
    try {
      final StudioModel studioModel = StudioModel(
        id: studio.id,
        studioName: studio.studioName,
        description: studio.description,
        imageUrl: studio.imageUrl,
        locationName: studio.locationName,
        studioTypeName: studio.studioTypeName,
        status: studio.status,
        acreage: studio.acreage,
        startTime: studio.startTime,
        endTime: studio.endTime,
      );
      await remoteDataSource.updateStudio(studioModel);
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to update data. Check your connection.');
    }
  }

  // --- THÊM TRIỂN KHAI HÀM MỚI ---
  @override
  Future<void> patchStudioStatus(String studioId, StudioStatus status) async {
    try {
      // Gọi hàm DataSource (sẽ sửa ở bước sau)
      await remoteDataSource.patchStudioStatus(studioId, status);
    } catch (e) {
      print(e.toString());
      // Cung cấp thông báo lỗi rõ ràng hơn
      throw Exception('Không thể cập nhật trạng thái studio. Lỗi: $e');
    }
  }
}
