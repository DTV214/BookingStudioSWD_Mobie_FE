// lib/features/profile/presentation/pages/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/account_profile.dart';
import '../provider/profile_provider.dart';

class EditProfilePage extends StatefulWidget {
  final Profile profile; // Trang này nhận profile hiện tại

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // 1. Tạo Controller cho các trường có thể sửa
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _avatarController;

  bool _isLoading = false; // Trạng thái loading cho nút Lưu

  @override
  void initState() {
    super.initState();
    // 2. Khởi tạo Controller với dữ liệu từ profile
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _avatarController = TextEditingController(
      text: widget.profile.avatarUrl ?? '',
    );
  }

  @override
  void dispose() {
    // 3. Huỷ Controller để tránh rò rỉ bộ nhớ
    _nameController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  // 4. Hàm xử lý khi nhấn nút "Lưu"
  Future<void> _onSave() async {
    if (_isLoading) return; // Nếu đang lưu thì không làm gì

    setState(() {
      _isLoading = true;
    });

    // Lấy provider
    final provider = Provider.of<ProfileProvider>(context, listen: false);

    // 5. Tạo đối tượng Profile mới với dữ liệu đã cập nhật
    // Lưu ý: các trường không được sửa (id, email, role)
    // chúng ta phải giữ nguyên từ `widget.profile`
    final updatedProfile = Profile(
      id: widget.profile.id, // ID không đổi
      email: widget.profile.email, // Email không đổi
      accountRole: widget.profile.accountRole, // Role không đổi
      userType: widget.profile.userType, // Type không đổi
      // Các trường lấy từ Controller
      fullName: _nameController.text,
      phoneNumber: _phoneController.text,
      avatarUrl: _avatarController.text.isNotEmpty
          ? _avatarController.text
          : null,
    );

    // 6. Gọi provider để lưu
    final bool success = await provider.saveProfile(updatedProfile);

    // 7. Xử lý kết quả
    if (mounted) {
      // Kiểm tra xem widget còn trên cây widget không
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cập nhật thành công!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Quay về trang Settings
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: ${provider.errorMessage}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa thông tin"),
        backgroundColor: const Color(0xFF6A40D3), // Màu tím
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === CÁC TRƯỜNG ĐƯỢC SỬA ===
            Text(
              "Thông tin có thể sửa",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Họ và tên",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Số điện thoại",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _avatarController,
              decoration: const InputDecoration(
                labelText: "Link ảnh đại diện (Cloudinary)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // === CÁC TRƯỜNG CHỈ ĐỌC ===
            Text(
              "Thông tin cố định",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField(
              icon: Icons.email,
              label: "Email",
              value: widget.profile.email,
            ),
            _buildReadOnlyField(
              icon: Icons.work,
              label: "Chức vụ",
              value: widget.profile.accountRole,
            ),
            _buildReadOnlyField(
              icon: Icons.person_search,
              label: "Loại tài khoản",
              value: widget.profile.userType,
            ),

            const SizedBox(height: 32),

            // === NÚT LƯU ===
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A40D3), // Màu nền
                  foregroundColor: Colors.white, // <-- ⭐ THÊM DÒNG NÀY ĐỂ SỬA
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Lưu thay đổi"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget nội bộ để hiển thị trường chỉ đọc
  Widget _buildReadOnlyField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true, // Chỉ đọc
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[200], // Nền xám
          border: const OutlineInputBorder(
            borderSide: BorderSide.none, // Không có viền
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }
}
