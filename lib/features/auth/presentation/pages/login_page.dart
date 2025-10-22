// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../layout/main_layout.dart'; // Import layout chính của bạn
import '../provider/auth_provider.dart';
import '../widgets/google_login_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Lắng nghe AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    // 2. Dùng Consumer để tự động build lại khi state thay đổi
    return Scaffold(
      backgroundColor: Color(0xFFF4F6F9),
      body: Consumer<AuthProvider>(
        builder: (context, provider, child) {
          // 3. Xử lý logic chuyển trang
          if (provider.state == AuthState.authenticated) {
            // Nếu đăng nhập thành công, chuyển ngay sang trang chính
            // Dùng addPostFrameCallback để đảm bảo việc build đã xong
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainLayout()),
              );
            });
            // Hiển thị 1 frame trống trong khi chờ chuyển trang
            return const Scaffold(
              body: Center(child: Text("Đăng nhập thành công!")),
            );
          }

          // 4. Xử lý UI
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo (Bạn có thể thay bằng logo app)
                const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Color(0xFF6A40D3),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Studio Manager",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Chào mừng! Vui lòng đăng nhập để tiếp tục.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 60),

                // 5. Nút bấm hoặc vòng xoay
                if (provider.state == AuthState.loading)
                  const Center(child: CircularProgressIndicator())
                else
                  GoogleLoginButton(
                    onPressed: () {
                      // Gọi hàm login từ provider
                      context.read<AuthProvider>().login();
                    },
                  ),

                const SizedBox(height: 20),

                // 6. Hiển thị lỗi nếu có
                if (provider.state == AuthState.error)
                  Text(
                    'Đã xảy ra lỗi: ${provider.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
