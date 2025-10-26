// lib/main.dart
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

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'features/auth/presentation/pages/login_page.dart';

// Import tất cả các lớp đã tạo
// Data
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

// Domain
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_with_google.dart';

// Presentation
import 'features/auth/presentation/provider/auth_provider.dart';

void main() async {
  // 1. Đảm bảo WidgetsBinding đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // === A. DEPENDENCIES (SINGLETONS) ===
        Provider<http.Client>(create: (_) => http.Client()),
        Provider<GoogleSignIn>(
          create: (_) => GoogleSignIn(
            serverClientId:
                "161293462080-uis6ondt03svjsdbqskcadknvt81rqrg.apps.googleusercontent.com",
          ),
        ),
        Provider<FlutterSecureStorage>(
          create: (_) => const FlutterSecureStorage(),
        ),

        // 1. AUTH - DATA
        ProxyProvider<FlutterSecureStorage, AuthLocalDataSource>(
          update: (_, storage, __) =>
              AuthLocalDataSourceImpl(secureStorage: storage),
        ),
        ProxyProvider2<GoogleSignIn, http.Client, AuthRemoteDataSource>(
          update: (_, googleSignIn, client, __) => AuthRemoteDataSourceImpl(
            googleSignIn: googleSignIn,
            client: client,
          ),
        ),

        // 2. AUTH - DOMAIN
        ProxyProvider2<
          AuthRemoteDataSource,
          AuthLocalDataSource,
          AuthRepository
        >(
          update: (_, remote, local, __) => AuthRepositoryImpl(
            remoteDataSource: remote,
            localDataSource: local,
          ),
        ),
        ProxyProvider<AuthRepository, LoginWithGoogle>(
          update: (_, repo, __) => LoginWithGoogle(repo),
        ),

        // 3. STUDIO - DATA & DOMAIN (Lấy từ main-origin.dart)
        // Provider<StudioRemoteDataSource>(
        //   create: (context) =>
        //       StudioRemoteDataSourceImpl(client: context.read<http.Client>()),
        // ),
        // Provider<StudioRepository>(
        //   create: (context) => StudioRepositoryImpl(
        //     remoteDataSource: context.read<StudioRemoteDataSource>(),
        //   ),
        // ),
        // 3. STUDIO - DATA & DOMAIN (ĐÃ SỬA)
        // Sử dụng ProxyProvider2 để tiêm AuthLocalDataSource VÀ http.Client
        ProxyProvider2<
          AuthLocalDataSource,
          http.Client,
          StudioRemoteDataSource
        >(
          update: (context, authLocal, client, previousDataSource) {
            // In ra để debug xem authLocal có null không
            print("[main.dart] Creating StudioRemoteDataSource...");
            print(
              "[main.dart] AuthLocalDataSource is null? ${authLocal == null}",
            );

            // Nếu authLocal null, có thể provider chưa sẵn sàng, trả về cái cũ (nếu có)
            if (authLocal == null) {
              print(
                "[main.dart] AuthLocalDataSource is NULL, returning previous instance.",
              );
              return previousDataSource ??
                  StudioRemoteDataSourceImpl(
                    client: client,
                    authLocalDataSource: authLocal,
                  ); // Cần cung cấp authLocal dù null để tránh lỗi type
            }

            print(
              "[main.dart] AuthLocalDataSource OK. Creating new StudioRemoteDataSourceImpl.",
            );
            return StudioRemoteDataSourceImpl(
              client: client,
              authLocalDataSource: authLocal, // Tiêm dependency vào đây
            );
          },
        ),
        ProxyProvider<StudioRemoteDataSource, StudioRepository>(
          update: (context, remoteData, previousRepository) {
            print("[main.dart] Creating StudioRepository...");
            print(
              "[main.dart] StudioRemoteDataSource is null? ${remoteData == null}",
            );
            if (remoteData == null) {
              print(
                "[main.dart] StudioRemoteDataSource is NULL, returning previous instance.",
              );
              return previousRepository ??
                  StudioRepositoryImpl(
                    remoteDataSource: remoteData,
                  ); // Cần cung cấp remoteData dù null
            }
            print(
              "[main.dart] StudioRemoteDataSource OK. Creating new StudioRepositoryImpl.",
            );
            return StudioRepositoryImpl(remoteDataSource: remoteData);
          },
        ),
        // (Thêm Studio Usecase ở đây khi bạn tạo)

        // 4. BOOKING - DATA & DOMAIN (Lấy từ main-origin.dart)
        // Trong MultiProvider -> providers:
        Provider<BookingRemoteDataSource>(
          create: (context) => BookingRemoteDataSourceImpl(
            client: context.read<http.Client>(),
            secureStorage: context.read<FlutterSecureStorage>(), // ✅ thêm dòng này
          ),
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

        // === B. STATE MANAGEMENT (CHANGE NOTIFIER PROVIDERS) ===

        // 1. AUTH - PRESENTATION (Giữ nguyên từ main.dart)
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            loginWithGoogleUseCase: context.read<LoginWithGoogle>(),
          ),
        ),

        // 2. STUDIO - PRESENTATION (Lấy từ main-origin.dart)
        ChangeNotifierProvider<StudioProvider>(
          create: (context) => StudioProvider(
            studioRepository: context.read<StudioRepository>(),
          ),
        ),

        // 3. BOOKING - PRESENTATION (Lấy từ main-origin.dart)
        ChangeNotifierProvider<BookingProvider>(
          create: (context) => BookingProvider(
            getBookingsUsecase: context.read<GetBookingsUsecase>(),
          ),
        ),
      ],
      // 2. MaterialApp
      child: MaterialApp(
        title: 'Studio Manager',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      ),
    );
  }
}
