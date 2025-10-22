import '../../domain/entities/studio.dart';
import '../../domain/repositories/studio_repository.dart';
import '../datasources/studio_remote_data_source.dart';
import '../models/studio_model.dart'; // Import model

class StudioRepositoryImpl implements StudioRepository {
  final StudioRemoteDataSource remoteDataSource;

  StudioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Studio>> getStudios() async {
    // ... (code hàm getStudios giữ nguyên) ...
    try {
      final List<Studio> remoteStudios = await remoteDataSource.getStudios();
      return remoteStudios;
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to fetch data. Check your connection.');
    }
  }

  // --- TRIỂN KHAI HÀM MỚI ---
  @override
  Future<void> updateStudio(Studio studio) async {
    try {
      // 1. Chuyển đổi Studio (Entity) sang StudioModel (Data)
      // Đây là một bước quan trọng, vì hàm toJson() nằm trong StudioModel

      // Chúng ta cần 1 cách để chuyển Studio -> StudioModel.
      // Cách 1: Thêm 1 hàm copyWith vào StudioModel
      // Cách 2: Tạo mới StudioModel từ Studio (dễ nhất)
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

      // 2. Gọi remoteDataSource
      await remoteDataSource.updateStudio(studioModel);
    } catch (e) {
      // Xử lý lỗi
      print(e.toString());
      throw Exception('Failed to update data. Check your connection.');
    }
  }
}
