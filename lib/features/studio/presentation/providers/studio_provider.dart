// lib/features/studio/presentation/providers/studio_provider.dart
import 'package:flutter/material.dart';
import 'package:swd_mobie_flutter/features/studio/domain/entities/studio.dart';
import 'package:swd_mobie_flutter/features/studio/domain/repositories/studio_repository.dart';


enum StudioState { initial, loading, loaded, error }

class StudioProvider extends ChangeNotifier {
  final StudioRepository studioRepository;

  StudioState _state = StudioState.initial;
  List<Studio> _studios = [];
  String _errorMessage = '';
  bool _isSaving = false;

  StudioState get state => _state;
  List<Studio> get studios => _studios;
  String get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;

  StudioProvider({required this.studioRepository});

  Future<void> fetchStudios() async {
    // ... (Giữ nguyên) ...
    _state = StudioState.loading;
    notifyListeners();
    try {
      _studios = await studioRepository.getStudios();
      _state = StudioState.loaded;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = StudioState.error;
      notifyListeners();
    }
  }

  // Hàm Cập nhật (PUT - Cập nhật tất cả, có thể bị 403)
  Future<bool> saveStudio(Studio updatedStudio) async {
    _isSaving = true;
    _errorMessage = '';
    notifyListeners();
    try {
      await studioRepository.updateStudio(updatedStudio);
      _isSaving = false;
      await fetchStudios();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // --- THÊM HÀM MỚI (PATCH - Chỉ cập nhật Status) ---
  Future<bool> updateStudioStatus(
    String studioId,
    StudioStatus newStatus,
  ) async {
    _isSaving = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Gọi hàm repository mới (sẽ sửa ở bước sau)
      await studioRepository.patchStudioStatus(studioId, newStatus);

      _isSaving = false;
      await fetchStudios(); // Tải lại danh sách
      return true; // Báo thành công
    } catch (e) {
      _errorMessage = e.toString();
      _isSaving = false;
      notifyListeners();
      return false; // Báo thất bại
    }
  }
  // ----------------------------------------------

  // Hàm Vô hiệu hóa (PATCH - status="DELETED")
  Future<bool> deleteStudio(String studioId) async {
    _isSaving = true;
    _errorMessage = '';
    notifyListeners();
    try {
      // Gọi hàm repository (sẽ sửa ở bước sau để nhận enum?)
      // Tạm thời vẫn gửi String "DELETED"
      await studioRepository.patchStudioStatus(studioId, StudioStatus.deleted);

      _isSaving = false;
      await fetchStudios();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
