// lib/main.dart
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:swd_mobie_flutter/features/booking/domain/entities/booking.dart';
import 'package:swd_mobie_flutter/features/booking/domain/usecases/get_booking_detail_usecase.dart';
import 'package:swd_mobie_flutter/features/booking/presentation/widgets/booking_detail_page.dart';

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

// ========== Push Notification ==========
import 'core/data/services/push_notification_service_impl.dart';
import 'core/domain/services/push_notification_service.dart';
import 'features/auth/domain/usecases/register_fcm_token.dart';

/// Enable Process Remote Message when app is closed
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // BẮT BUỘC: Cần khởi tạo Firebase lần nữa trong Top-Level handler
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

// GLOBAL KEY FOR NAVIGATION
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
        Provider<FlutterSecureStorage>(
          create: (_) => const FlutterSecureStorage(),
        ),

        // ===== AUTH - DATA =====
        ProxyProvider<FlutterSecureStorage, AuthLocalDataSource>(
          update: (_, storage, __) =>
              AuthLocalDataSourceImpl(secureStorage: storage),
        ),
        ProxyProvider3<
          GoogleSignIn,
          http.Client,
          AuthLocalDataSource,
          AuthRemoteDataSource
        >(
          update: (_, googleSignIn, client, localDataSource, __) =>
              AuthRemoteDataSourceImpl(
                googleSignIn: googleSignIn,
                client: client,
                localDataSource: localDataSource,
              ),
        ),

        // ===== AUTH - DOMAIN =====
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
        ProxyProvider<AuthRepository, RegisterFCMToken>(
          update: (_, repo, __) => RegisterFCMToken(repo),
        ),

        // ===== STUDIO - DATA & DOMAIN (gọn, không trùng lặp) =====
        ProxyProvider2<
          AuthLocalDataSource,
          http.Client,
          StudioRemoteDataSource
        >(
          update: (_, authLocal, client, __) => StudioRemoteDataSourceImpl(
            client: client,
            authLocalDataSource: authLocal,
          ),
        ),
        ProxyProvider<StudioRemoteDataSource, StudioRepository>(
          update: (_, remote, __) =>
              StudioRepositoryImpl(remoteDataSource: remote),
        ),
        ProxyProvider2<
          http.Client,
          AuthLocalDataSource,
          ProfileRemoteDataSource
        >(
          update: (_, client, authLocal, __) => ProfileRemoteDataSourceImpl(
            client: client,
            authLocalDataSource: authLocal,
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
          create: (context) => BookingRepositoryImpl(
            remoteDataSource: context.read<BookingRemoteDataSource>(),
          ),
        ),
        Provider<GetBookingsUsecase>(
          create: (context) =>
              GetBookingsUsecase(context.read<BookingRepository>()),
        ),
        Provider<GetBookingDetailUsecase>(
          create: (context) =>
              GetBookingDetailUsecase(context.read<BookingRepository>()),
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

        // 5. CORE - SERVICES (MỚI)
        ProxyProvider<GetBookingDetailUsecase, PushNotificationService>(
          update: (_, getDetailUsecase, __) => PushNotificationServiceImpl(
            getBookingDetailUsecase: getDetailUsecase,
          ),
        ),

        // ===== B. PRESENTATION (ChangeNotifier) =====
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            loginWithGoogleUseCase: context.read<LoginWithGoogle>(),
            registerFCMTokenUseCase: context.read<RegisterFCMToken>(),
            pushNotificationService: context.read<PushNotificationService>(),
          ),
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
        navigatorKey: navigatorKey,
        routes: {
          '/booking_detail': (context) {
            // 1. Extract argument
            final booking = ModalRoute.of(context)?.settings.arguments as Booking;

            // 2. Redirect Page
            return BookingDetailPage(booking: booking);
          }
        },
      ),
    );
  }
}
