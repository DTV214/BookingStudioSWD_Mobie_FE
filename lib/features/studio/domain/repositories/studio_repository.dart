// lib/features/studio/domain/repositories/studio_repository.dart
import '../entities/studio.dart';

// Đây là "hợp đồng"
// Nó chỉ nói: "AI đó phải cung cấp 1 hàm getStudios trả về 1 List<Studio>"
// Nó không quan tâm là lấy từ API, database, hay code cứng.
abstract class StudioRepository {
  // Chúng ta dùng Future vì gọi API là một hành động bất đồng bộ
  Future<List<Studio>> getStudios();
  Future<void> updateStudio(Studio studio);
  // Sau này bạn có thể thêm:
  // Future<Studio> getStudioById(String id);
  // Future<void> updateStudio(Studio studio);
}
