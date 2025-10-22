import 'package:flutter/material.dart';
// Import các file gốc của bạn
import 'layout/main_layout.dart';
import 'core/theme/app_theme.dart';

// 1. Thêm các import cho Provider và Clean Architecture
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'features/studio/data/datasources/studio_remote_data_source.dart';
import 'features/studio/data/repositories/studio_repository_impl.dart';
import 'features/studio/domain/repositories/studio_repository.dart';
import 'features/studio/presentation/providers/studio_provider.dart';

void main() {
  // 2. Bọc toàn bộ ứng dụng bằng MultiProvider
  runApp(
    MultiProvider(
      providers: [
        // --- Cung cấp các lớp Data & Domain (chỉ tạo 1 lần) ---

        // Cung cấp 1 http.Client
        Provider<http.Client>(
          create: (_) => http.Client(),
          // dispose: (_, client) => client.close(), // Tùy chọn: tự động đóng client
        ),

        // Cung cấp DataSource (nó sẽ tự tìm http.Client ở trên)
        Provider<StudioRemoteDataSource>(
          create: (context) =>
              StudioRemoteDataSourceImpl(client: context.read<http.Client>()),
        ),

        // Cung cấp Repository (nó sẽ tự tìm DataSource ở trên)
        Provider<StudioRepository>(
          create: (context) => StudioRepositoryImpl(
            remoteDataSource: context.read<StudioRemoteDataSource>(),
          ),
        ),

        // --- Cung cấp các lớp State/Notifier (UI sẽ lắng nghe) ---

        // Cung cấp StudioProvider (nó sẽ tự tìm Repository ở trên)
        ChangeNotifierProvider<StudioProvider>(
          create: (context) => StudioProvider(
            studioRepository: context.read<StudioRepository>(),
          ),
        ),

        // (Sau này bạn có thể thêm các Provider khác ở đây,
        // ví dụ: BookingProvider, AuthProvider...)
      ],
      // 3. child chính là const MyApp() của bạn
      child: const MyApp(),
    ),
  );
}

// 4. Class MyApp của bạn giữ nguyên, không cần thay đổi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Footer Menu', // Giữ nguyên title của bạn
      theme: AppTheme.lightTheme, // Giữ nguyên theme của bạn
      home: const MainLayout(), // Giữ nguyên home của bạn
      debugShowCheckedModeBanner: false, // Thêm dòng này để tắt banner "DEBUG"
    );
  }
}
