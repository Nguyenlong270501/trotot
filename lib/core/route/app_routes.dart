import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/appointment/data/models/appointment_model.dart';
import '../../features/appointment/data/repositories/appointment_repository.dart';
import '../../features/appointment/presentation/blocs/appointment_create/appointment_create_cubit.dart';
import '../../features/appointment/presentation/blocs/appointment_form/appointment_form_cubit.dart';
import '../../features/appointment/presentation/screens/appointment_screen.dart';
import '../../features/auth/blocs/auth_blocs/auth_cubit.dart';
import '../../features/auth/blocs/auth_blocs/auth_state.dart';
import '../../features/auth/blocs/forget_password_form/forget_password_form_cubit.dart';
import '../../features/auth/blocs/sign_in_form/sign_in_form_cubit.dart';
import '../../features/auth/blocs/sign_up_form/sign_up_form_cubit.dart';
import '../../features/home/data/models/property_model.dart';
import '../../features/home/data/models/room_model.dart';
import '../../features/favorites/data/repositories/favorite_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/profile/presentation/screens/security_password/security_password_screen.dart';
import '../../features/profile/presentation/screens/change_password/change_password_screen.dart';
import '../../features/profile/blocs/change_password_form/change_password_form_cubit.dart';
import '../../features/home/blocs/property_details_live/property_details_live_cubit.dart';
import '../../features/home/data/datasources/firebase_home_remote_datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/property_details_live_repository.dart';
import '../../features/home/presentation/screens/property_details.dart/property_details_screen.dart';
import '../../features/profile/blocs/landlord_status/landlord_status_cubit.dart';
import '../../features/profile/blocs/profile_edit/profile_edit_cubit.dart';
import '../../features/profile/blocs/profile_image.dart/profile_image_cubit.dart';
import '../../features/profile/data/models/landlord_request.dart';
import '../../features/profile/data/repositories/landlord_register_repository.dart';
import '../../features/profile/data/repositories/profile_image_repository.dart';
import '../../features/reviews/data/repositories/reviews_repository.dart';
import '../../features/profile/presentation/screens/edit_profile/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/landlord_register/landlord_register_screen.dart';
import '../../features/auth/data/models/user.dart';
import '../../features/auth/presentation/screens/signup/sign_up_screen.dart';
import '../../features/auth/presentation/screens/signin/sign_in_screen.dart';
import '../../features/auth/presentation/screens/forget_password/forget_password_screen.dart';
import '../../features/home/presentation/screens/home/home_screen.dart';
import '../../features/search/presentations/filter_results_screen.dart';
import '../../features/search/presentations/search_screen/search_screen.dart';
import '../../features/splash/splash_screen.dart';

class RouteNames {
  static const String loginpage = '/login';
  static const String signuppage = '/signup';
  static const String forgetPasswordPage = '/forget-password';
  static const String homepage = '/homepage';
  static const String editProfilePage = '/edit-profile';
  static const String landlordRegisterPage = '/landlord-register';
  static const String propertyDetailsPage = '/property-details';
  static const String searchPage = '/search';
  static const String filterResultsPage = '/filter-results';
  static const String appointmentPage = '/appointment';
  static const String securityPasswordPage = '/security-password';
  static const String changePasswordPage = '/change-password';
}

class AppRoutes {
  static final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/',
        name: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: RouteNames.loginpage,
        name: RouteNames.loginpage,
        builder: (context, state) {
          return BlocProvider<SignInFormCubit>(
            create: (context) => SignInFormCubit(),
            child: const SignInScreen(),
          );
        },
      ),

      GoRoute(
        path: RouteNames.signuppage,
        name: RouteNames.signuppage,
        builder: (context, state) {
          return BlocProvider<SignUpFormCubit>(
            create: (context) => SignUpFormCubit(),
            child: const SignUpScreen(),
          );
        },
      ),

      GoRoute(
        path: RouteNames.forgetPasswordPage,
        name: RouteNames.forgetPasswordPage,
        builder: (context, state) {
          return BlocProvider<ForgetPasswordFormCubit>(
            create: (context) => ForgetPasswordFormCubit(),
            child: const ForgetPasswordScreen(),
          );
        },
      ),

      GoRoute(
        path: RouteNames.homepage,
        name: RouteNames.homepage,
        builder: (context, state) {
          var initialBottomNavIndex = 0;
          var initialMessagesTabIndex = 0;
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            initialBottomNavIndex =
                extra['initialBottomNavIndex'] as int? ?? 0;
            initialMessagesTabIndex =
                extra['initialMessagesTabIndex'] as int? ?? 0;
          }

          return BlocProvider<LandlordStatusCubit>(
            create: (context) => LandlordStatusCubit(
              repository: context.read<LandlordRegisterRepository>(),
            ),
            child: HomeScreen(
              initialBottomNavIndex: initialBottomNavIndex,
              initialMessagesTabIndex: initialMessagesTabIndex,
            ),
          );
        },
      ),

      GoRoute(
        path: RouteNames.editProfilePage,
        name: RouteNames.editProfilePage,
        builder: (context, state) {
          final user = state.extra is UserModel
              ? state.extra as UserModel
              : null;
          return MultiBlocProvider(
            providers: [
              BlocProvider<ProfileImageCubit>(
                create: (context) => ProfileImageCubit(
                  context.read<ProfileImageRepository>(),
                  initialAvatarUrl: user?.avatarUrl ?? '',
                ),
              ),
              BlocProvider<ProfileEditCubit>(
                create: (context) => ProfileEditCubit(
                  initialName: user?.userName ?? '',
                  initialPhone: user?.phoneNumber ?? '',
                  repository: context.read<ProfileImageRepository>(),
                ),
              ),
            ],
            child: EditProfileScreen(user: user),
          );
        },
      ),

      GoRoute(
        path: RouteNames.landlordRegisterPage,
        name: RouteNames.landlordRegisterPage,
        builder: (context, state) {
          final request = state.extra as LandlordRequest?;
          return LandlordRegisterScreen(existingRequest: request);
        },
      ),

      GoRoute(
        path: RouteNames.propertyDetailsPage,
        name: RouteNames.propertyDetailsPage,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            return const Scaffold(
              body: Center(child: Text('Lỗi: Không tìm thấy dữ liệu khu trọ!')),
            );
          }
          final property = extra['property'] as PropertyModel;
          final rooms = extra['rooms'] as List<RoomModel>;
          final initialActiveRoomId = extra['initialActiveRoomId'] as String?;
          final authState = context.read<AuthenticationCubit>().state;
          final userId = authState is AuthenticationSuccessState
              ? authState.user.userId
              : null;

          return MultiBlocProvider(
            providers: [
              BlocProvider<PropertyDetailsLiveCubit>(
                create: (context) => PropertyDetailsLiveCubit(
                  liveRepository: PropertyDetailsLiveRepository(
                    homeRemote: context.read<HomeRemoteDataSource>(),
                    favoriteRepository: context.read<FavoriteRepository>(),
                    reviewsRepository: context.read<ReviewsRepository>(),
                    appointmentRepository: context
                        .read<AppointmentRepository>(),
                  ),
                  favoriteRepository: context.read<FavoriteRepository>(),
                  currentUserId: userId,
                  initialProperty: property,
                  initialRooms: rooms,
                  initialActiveRoomId: initialActiveRoomId,
                )..start(),
              ),
            ],
            child: PropertyDetailsScreen(property: property, rooms: rooms),
          );
        },
      ),

      GoRoute(
        path: RouteNames.searchPage,
        name: RouteNames.searchPage,
        builder: (context, state) => const SearchScreen(),
      ),

      GoRoute(
        path: RouteNames.filterResultsPage,
        name: RouteNames.filterResultsPage,
        builder: (context, state) => const FilterResultsScreen(),
      ),

      GoRoute(
        path: RouteNames.securityPasswordPage,
        name: RouteNames.securityPasswordPage,
        builder: (context, state) => const SecurityPasswordScreen(),
      ),

      GoRoute(
        path: RouteNames.changePasswordPage,
        name: RouteNames.changePasswordPage,
        builder: (context, state) {
          return BlocProvider<ChangePasswordFormCubit>(
            create: (context) =>
                ChangePasswordFormCubit(context.read<AuthRepositoryImpl>()),
            child: const ChangePasswordScreen(),
          );
        },
      ),

      GoRoute(
        path: RouteNames.appointmentPage,
        name: RouteNames.appointmentPage,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null ||
              extra['property'] is! PropertyModel ||
              extra['rooms'] is! List<RoomModel>) {
            return const Scaffold(
              body: Center(child: Text('Lỗi: Không có dữ liệu lịch hẹn')),
            );
          }
          return MultiBlocProvider(
            providers: [
              BlocProvider<AppointmentCreateCubit>(
                create: (context) => AppointmentCreateCubit(
                  context.read<AppointmentRepository>(),
                ),
              ),
              BlocProvider<AppointmentFormCubit>(
                create: (_) => AppointmentFormCubit(),
              ),
            ],
            child: AppointmentScreen(
              property: extra['property'] as PropertyModel,
              rooms: extra['rooms'] as List<RoomModel>,
              initialAppointment: extra['initialAppointment'] is AppointmentModel
                  ? extra['initialAppointment'] as AppointmentModel
                  : null,
            ),
          );
        },
      ),
    ],
  );
}
