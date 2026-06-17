import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import '../../core/route/app_routes.dart';
import '../../core/services/local_location_service.dart';
import '../auth/blocs/auth_blocs/auth_cubit.dart';
import '../auth/blocs/auth_blocs/auth_state.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocalLocationService().loadData();
      if (mounted) {
        context.read<AuthenticationCubit>().checkAuthStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: BlocListener<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationSuccessState) {
            context.go(RouteNames.homepage);
            FlutterNativeSplash.remove(); 
          } else if (state is UnAuthenticationState || state is AuthenticationErrorState) {
            context.go(RouteNames.loginpage);
            FlutterNativeSplash.remove(); 
          }
        },
        child: const SizedBox.shrink(), 
      ),
    );
  }
}