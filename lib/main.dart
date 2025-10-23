import 'package:flutter/material.dart';
import 'package:swd_mobie_flutter/features/booking/data/datasources/booking_remote_data_source_impl.dart';
import 'package:swd_mobie_flutter/features/booking/data/repositories/booking_repository_impl.dart';
// Import các file gốc của bạn
import 'layout/main_layout.dart';
import 'core/theme/app_theme.dart';

// 1. Thêm các import cho Provider và Clean Architecture
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// --- Imports cho Studio (Bạn đã có) ---
import 'features/studio/data/datasources/studio_remote_data_source.dart';
// (Bạn bị thiếu import Impl cho Studio, tôi thêm vào nhé)

import 'features/studio/data/repositories/studio_repository_impl.dart';
import 'features/studio/domain/repositories/studio_repository.dart';
// (Bạn nên tạo usecase cho studio)
// import 'features/studio/domain/usecases/get_studios_usecase.dart';
import 'features/studio/presentation/providers/studio_provider.dart';

// --- Imports cho Booking (Chúng ta vừa tạo) ---
import 'features/booking/data/datasources/booking_remote_data_source.dart';

import 'features/booking/domain/repositories/booking_repository.dart';
import 'features/booking/domain/usecases/get_bookings_usecase.dart';
import 'features/booking/presentation/providers/booking_provider.dart';

void main() {
  // 2. Bọc toàn bộ ứng dụng bằng MultiProvider
  runApp(
    MultiProvider(
      providers: [
        // --- Cung cấp các lớp Data & Domain (chỉ tạo 1 lần) ---

        // Cung cấp 1 http.Client (Dùng chung cho cả Studio và Booking)
        Provider<http.Client>(
          create: (_) => http.Client(),
          // dispose: (_, client) => client.close(), // Tùy chọn: tự động đóng client
        ),

        // --- Providers cho Studio (Như cũ của bạn) ---
        Provider<StudioRemoteDataSource>(
          create: (context) =>
              StudioRemoteDataSourceImpl(client: context.read<http.Client>()),
        ),
        Provider<StudioRepository>(
          create: (context) => StudioRepositoryImpl(
            remoteDataSource: context.read<StudioRemoteDataSource>(),
          ),
        ),
        // (Bạn nên thêm GetStudiosUsecase ở đây)

        // --- Providers cho Booking (Mới) ---
        Provider<BookingRemoteDataSource>(
          create: (context) =>
              BookingRemoteDataSourceImpl(client: context.read<http.Client>()),
        ),
        Provider<BookingRepository>(
          create: (context) => BookingRepositoryImpl(
            remoteDataSource: context.read<BookingRemoteDataSource>(),
          ),
        ),
        Provider<GetBookingsUsecase>(
          create: (context) =>
              GetBookingsUsecase(context.read<BookingRepository>()),
        ),

        // --- Cung cấp các lớp State/Notifier (UI sẽ lắng nghe) ---

        // StudioProvider
        ChangeNotifierProvider<StudioProvider>(
          create: (context) => StudioProvider(
            studioRepository: context.read<StudioRepository>(),
            // (Sau này nên đổi thành usecase)
          ),
        ),

        // BookingProvider (Mới)
        ChangeNotifierProvider<BookingProvider>(
          create: (context) {
            // LOG MỚI: Thêm vào đây
            print(
              "[main.dart] Đang tạo BookingProvider... (Nếu thấy dòng này là tốt)",
            );
            return BookingProvider(
              getBookingsUsecase: context.read<GetBookingsUsecase>(),
            );
          },
        ),

        // (Sau này bạn có thể thêm các Provider khác ở đây)
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
