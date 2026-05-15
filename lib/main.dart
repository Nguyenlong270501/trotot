import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/route/app_routes.dart';
import 'core/services/fcm_service.dart';
import 'features/auth/blocs/auth_blocs/auth_cubit.dart';
import 'features/auth/data/datasources/firebase_auth_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/appointment/data/datasources/appointment_remote_data_source.dart';
import 'features/appointment/data/datasources/firebase_appointment_remote_data_source.dart';
import 'features/appointment/data/repositories/appointment_repository.dart';
import 'features/appointment/data/repositories/appointment_repository_impl.dart';
import 'features/favorites/data/datasources/favorite_remote_data_source.dart';
import 'features/favorites/data/datasources/firebase_favorite_remote_data_source.dart';
import 'features/favorites/data/repositories/favorite_repository.dart';
import 'features/favorites/data/repositories/favorite_repository_impl.dart';
import 'features/home/data/datasources/firebase_home_remote_datasources/firebase_home_remote_data_source.dart';
import 'features/home/data/datasources/firebase_home_remote_datasources/home_remote_data_source.dart';
import 'features/home/data/repositories/home_repository.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/messages/data/datasources/firebase_messages_remote_data_source.dart';
import 'features/messages/data/datasources/messages_remote_data_source.dart';
import 'features/messages/data/repositories/messages_repository.dart';
import 'features/messages/data/repositories/messages_repository_impl.dart';
import 'features/profile/data/repositories/landlord_register_repository.dart';
import 'features/profile/data/repositories/profile_image_repository.dart';
import 'features/reviews/data/datasources/firebase_reviews_remote_data_source.dart';
import 'features/reviews/data/datasources/reviews_remote_data_source.dart';
import 'features/reviews/data/repositories/reviews_repository.dart';
import 'features/reviews/data/repositories/reviews_repository_impl.dart';
import 'features/search/blocs/room_filter/room_filter_cubit.dart';
import 'firebase_options.dart';

final _appRouter = AppRoutes().router;

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Hive.initFlutter();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FCMService().initialize(router: _appRouter);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepositoryImpl>(
          create: (context) => AuthRepositoryImpl(FirebaseAuthDataSource()),
        ),
        RepositoryProvider<ProfileImageRepository>(
          create: (context) => ProfileImageRepository(),
        ),
        RepositoryProvider<LandlordRegisterRepository>(
          create: (context) => LandlordRegisterRepository(),
        ),
        RepositoryProvider<HomeRemoteDataSource>(
          create: (context) => FirebaseHomeRemoteDataSource(),
        ),
        RepositoryProvider<FavoriteRemoteDataSource>(
          create: (context) => FirebaseFavoriteRemoteDataSource(),
        ),
        RepositoryProvider<AppointmentRemoteDataSource>(
          create: (context) => FirebaseAppointmentRemoteDataSource(),
        ),
        RepositoryProvider<MessagesRemoteDataSource>(
          create: (context) => FirebaseMessagesRemoteDataSource(),
        ),
        RepositoryProvider<ReviewsRemoteDataSource>(
          create: (context) => FirebaseReviewsRemoteDataSource(),
        ),
        RepositoryProvider<HomeRepository>(
          create: (context) =>
              HomeRepositoryImpl(context.read<HomeRemoteDataSource>()),
        ),
        RepositoryProvider<FavoriteRepository>(
          create: (context) =>
              FavoriteRepositoryImpl(context.read<FavoriteRemoteDataSource>()),
        ),
        RepositoryProvider<AppointmentRepository>(
          create: (context) => AppointmentRepositoryImpl(
            context.read<AppointmentRemoteDataSource>(),
          ),
        ),
        RepositoryProvider<MessagesRepository>(
          create: (context) =>
              MessagesRepositoryImpl(context.read<MessagesRemoteDataSource>()),
        ),
        RepositoryProvider<ReviewsRepository>(
          create: (context) =>
              ReviewsRepositoryImpl(context.read<ReviewsRemoteDataSource>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationCubit>(
            create: (context) => AuthenticationCubit(
              authRepository: context.read<AuthRepositoryImpl>(),
            ),
          ),
          BlocProvider<RoomFilterCubit>(
            create: (context) =>
                RoomFilterCubit(context.read<HomeRepository>()),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (BuildContext context, Widget? child) {
            return MaterialApp.router(
              routerConfig: _appRouter,
              debugShowCheckedModeBanner: false,
              title: 'Trọ Tốt',
              themeMode: ThemeMode.light,
              builder: (context, routerChild) {
                return GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: routerChild,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
