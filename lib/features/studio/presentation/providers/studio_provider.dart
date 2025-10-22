import 'package:flutter/material.dart';
import '../../domain/entities/studio.dart';
import '../../domain/repositories/studio_repository.dart';

// 1. Định nghĩa các trạng thái có thể xảy ra
enum StudioState { initial, loading, loaded, error }

// 2. Class Provider sẽ extends ChangeNotifier
class StudioProvider extends ChangeNotifier {
  final StudioRepository studioRepository;

  // 3. Quản lý các biến trạng thái
  StudioState _state = StudioState.initial;
  List<Studio> _studios = [];
  String _errorMessage = '';

  // --- THÊM TRẠNG THÁI LƯU ---
  bool _isSaving = false;
  // -------------------------

  // 4. Cung cấp "getter" để UI có thể đọc (an toàn)
  StudioState get state => _state;
  List<Studio> get studios => _studios;
  String get errorMessage => _errorMessage;
  // --- THÊM GETTER MỚI ---
  bool get isSaving => _isSaving;
  // -----------------------

  // 5. Constructor (hàm khởi tạo)
  StudioProvider({required this.studioRepository});

  // 6. Hàm để UI gọi và bắt đầu tải dữ liệu
  Future<void> fetchStudios() async {
    // ... (code hàm fetchStudios giữ nguyên) ...
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

  // --- THÊM HÀM LƯU MỚI ---
  // Hàm này sẽ được gọi từ trang Edit Studio
  // Nó trả về bool (true = thành công, false = thất bại)
  Future<bool> saveStudio(Studio updatedStudio) async {
    _isSaving = true;
    _errorMessage = ''; // Xóa lỗi cũ
    notifyListeners();

    try {
      // 1. Gọi Repository để cập nhật
      await studioRepository.updateStudio(updatedStudio);

      // 2. Cập nhật thành công!
      _isSaving = false;

      // 3. Quan trọng: Tải lại danh sách studio để đồng bộ
      await fetchStudios();
      // (notifyListeners() đã được gọi bên trong fetchStudios)

      return true; // Báo thành công
    } catch (e) {
      // 4. Cập nhật thất bại
      _errorMessage = e.toString();
      _isSaving = false;
      notifyListeners();
      return false; // Báo thất bại
    }
  }
}
