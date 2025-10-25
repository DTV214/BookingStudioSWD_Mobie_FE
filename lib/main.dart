// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/theme/app_theme.dart';
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

void main() async{
  // 1. Đảm bảo WidgetsBinding đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

        // 1. SỬA LỖI CHÍNH Ở ĐÂY
        // Cung cấp Web Client ID của bạn khi khởi tạo
        Provider<GoogleSignIn>(
          create: (_) => GoogleSignIn(
            serverClientId:
                "161293462080-uis6ondt03svjsdbqskcadknvt81rqrg.apps.googleusercontent.com",
          ),
        ),

        Provider<FlutterSecureStorage>(
          create: (_) => const FlutterSecureStorage(),
        ),

        // Provider cho Lớp Data
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

        // Provider cho Lớp Domain
        ProxyProvider2<AuthRemoteDataSource, AuthLocalDataSource,
            AuthRepository>(
          update: (_, remote, local, __) => AuthRepositoryImpl(
            remoteDataSource: remote,
            localDataSource: local,
          ),
        ),
        ProxyProvider<AuthRepository, LoginWithGoogle>(
          update: (_, repo, __) => LoginWithGoogle(repo),
        ),

        // === B. STATE MANAGEMENT (PROVIDER) ===
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            loginWithGoogleUseCase: context.read<LoginWithGoogle>(),
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
