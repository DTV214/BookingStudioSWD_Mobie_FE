// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:swd_mobie_flutter/features/account/data/datasources/account_remote_data_source.dart';
import 'package:swd_mobie_flutter/features/account/data/repositories/profile_repository_impl.dart';
import 'package:swd_mobie_flutter/features/account/domain/repositories/account_repository.dart';
import 'package:swd_mobie_flutter/features/account/domain/usecases/get_profile.dart';
import 'package:swd_mobie_flutter/features/account/domain/usecases/update_profile.dart';
import 'package:swd_mobie_flutter/features/account/presentation/provider/profile_provider.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'layout/main_layout.dart';

// ========== AUTH ==========
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/provider/auth_provider.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_with_google.dart';

// ========== STUDIO ==========
import 'features/studio/data/datasources/studio_remote_data_source.dart';
import 'features/studio/data/repositories/studio_repository_impl.dart';
import 'features/studio/domain/repositories/studio_repository.dart';
import 'features/studio/presentation/providers/studio_provider.dart';

// ========== BOOKING ==========
import 'features/booking/data/datasources/booking_remote_data_source.dart';
import 'features/booking/data/datasources/booking_remote_data_source_impl.dart';
import 'features/booking/data/repositories/booking_repository_impl.dart';
import 'features/booking/domain/repositories/booking_repository.dart';
import 'features/booking/domain/usecases/get_bookings_usecase.dart';
import 'features/booking/presentation/providers/booking_provider.dart';

// ========== SERVICE ASSIGN (thêm mới) ==========
import 'features/booking/data/datasources/service_assign_remote_data_source.dart';
import 'features/booking/data/datasources/service_assign_remote_data_source_impl.dart';
import 'features/booking/data/repositories/service_assign_repository_impl.dart';
import 'features/booking/domain/repositories/service_assign_repository.dart';
import 'features/booking/domain/usecases/get_service_assigns_by_studio_assign_usecase.dart';
import 'features/booking/presentation/providers/service_assign_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ===== A. DEPENDENCIES =====
        Provider<http.Client>(create: (_) => http.Client()),
        Provider<GoogleSignIn>(
          create: (_) => GoogleSignIn(
            serverClientId:
            "161293462080-uis6ondt03svjsdbqskcadknvt81rqrg.apps.googleusercontent.com",
          ),
        ),
        Provider<FlutterSecureStorage>(create: (_) => const FlutterSecureStorage()),

        // ===== AUTH - DATA =====
        ProxyProvider<FlutterSecureStorage, AuthLocalDataSource>(
          update: (_, storage, __) => AuthLocalDataSourceImpl(secureStorage: storage),
        ),
        ProxyProvider2<GoogleSignIn, http.Client, AuthRemoteDataSource>(
          update: (_, googleSignIn, client, __) =>
              AuthRemoteDataSourceImpl(googleSignIn: googleSignIn, client: client),
        ),

        // ===== AUTH - DOMAIN =====
        ProxyProvider2<AuthRemoteDataSource, AuthLocalDataSource, AuthRepository>(
          update: (_, remote, local, __) =>
              AuthRepositoryImpl(remoteDataSource: remote, localDataSource: local),
        ),
        ProxyProvider<AuthRepository, LoginWithGoogle>(
          update: (_, repo, __) => LoginWithGoogle(repo),
        ),

        // ===== STUDIO - DATA & DOMAIN (gọn, không trùng lặp) =====
        ProxyProvider2<AuthLocalDataSource, http.Client, StudioRemoteDataSource>(
          update: (_, authLocal, client, __) =>
              StudioRemoteDataSourceImpl(client: client, authLocalDataSource: authLocal),
        ),
        ProxyProvider<StudioRemoteDataSource, StudioRepository>(
          update: (_, remote, __) => StudioRepositoryImpl(remoteDataSource: remote),
        ),
          ProxyProvider2<http.Client, AuthLocalDataSource, ProfileRemoteDataSource>(
          update: (_, client, authLocal, __) => ProfileRemoteDataSourceImpl(
            client: client,
            authLocalDataSource: authLocal, // Dùng lại AuthLocal
          ),
        ),

        ProxyProvider2<
          http.Client,
          AuthLocalDataSource,
          ProfileRemoteDataSource
        >(
          update: (_, client, authLocal, __) => ProfileRemoteDataSourceImpl(
            client: client,
            authLocalDataSource: authLocal, // Dùng lại AuthLocal
          ),
        ),
        // ===== BOOKING - DATA & DOMAIN =====
        Provider<BookingRemoteDataSource>(
          create: (context) => BookingRemoteDataSourceImpl(
            client: context.read<http.Client>(),
            secureStorage: context.read<FlutterSecureStorage>(),
          ),
        ),
        Provider<BookingRepository>(
          create: (context) =>
              BookingRepositoryImpl(remoteDataSource: context.read<BookingRemoteDataSource>()),
        ),
        Provider<GetBookingsUsecase>(
          create: (context) => GetBookingsUsecase(context.read<BookingRepository>()),
        ),
        ProxyProvider<ProfileRemoteDataSource, ProfileRepository>(
          update: (_, remote, __) =>
              ProfileRepositoryImpl(remoteDataSource: remote),
        ),
        ProxyProvider<ProfileRepository, GetProfile>(
          update: (_, repo, __) => GetProfile(repo),
        ),
        ProxyProvider<ProfileRepository, UpdateProfile>(
          update: (_, repo, __) => UpdateProfile(repo),
        ),

//         // ===== SERVICE ASSIGN - DATA & DOMAIN =====
//         ProxyProvider2<FlutterSecureStorage, http.Client, ServiceAssignRemoteDataSource>(
//           update: (_, storage, client, __) =>
//               ServiceAssignRemoteDataSourceImpl(
//                 client: client,
//                 secureStorage: storage,
//               ),
//         ),
//
//         // ✅ BỔ SUNG: Repository từ RemoteDataSource
//         ProxyProvider<ServiceAssignRemoteDataSource, ServiceAssignRepository>(
//           update: (_, remote, __) =>
//               ServiceAssignRepositoryImpl(remoteDataSource: remote),
//         ),
//
// // Usecase đọc từ Repository (phải đặt SAU provider Repository)
//         Provider<GetServiceAssignsByStudioAssign>(
//           create: (ctx) =>
//               GetServiceAssignsByStudioAssign(ctx.read<ServiceAssignRepository>()),
//         ),
//
// // ChangeNotifier đọc từ Usecase
//         ChangeNotifierProvider<ServiceAssignProvider>(
//           create: (ctx) => ServiceAssignProvider(
//             getUsecase: ctx.read<GetServiceAssignsByStudioAssign>(),
//           ),
//         ),


        // ===== B. PRESENTATION (ChangeNotifier) =====
        ChangeNotifierProvider<AuthProvider>(
          create: (context) =>
              AuthProvider(loginWithGoogleUseCase: context.read<LoginWithGoogle>()),
        ),
        ChangeNotifierProvider<StudioProvider>(
          create: (context) => StudioProvider(
            studioRepository: context.read<StudioRepository>(),
          ),
        ),
        ChangeNotifierProvider<BookingProvider>(
          create: (context) => BookingProvider(
            getBookingsUsecase: context.read<GetBookingsUsecase>(),
          ),
        ),
        // Provider cho trang StudioAssignDetailPage
        ChangeNotifierProvider<ServiceAssignProvider>(
          create: (ctx) => ServiceAssignProvider(
            getUsecase: ctx.read<GetServiceAssignsByStudioAssign>(),
          ),
        ),
// ===== PROFILE - PRESENTATION =====
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) => ProfileProvider(
            getProfile: context.read<GetProfile>(),
            updateProfile: context.read<UpdateProfile>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Studio Manager',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      ),
    );
  }
}
