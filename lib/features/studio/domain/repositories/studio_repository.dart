import 'package:swd_mobie_flutter/features/studio/domain/entities/studio.dart';

abstract class StudioRepository {
  Future<List<Studio>> getStudios();
  Future<void> updateStudio(Studio studio);

  // --- THÊM HÀM MỚI ---
  Future<void> patchStudioStatus(String studioId, StudioStatus status);
}
