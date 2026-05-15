import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/route/app_routes.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../../../core/widgets/aurora_background.dart';
import '../../../blocs/auth_blocs/auth_cubit.dart';
import '../../../blocs/auth_blocs/auth_state.dart';
import '../../widgets/auth_divider.dart';
import '../../widgets/auth_oauth.dart';
import 'sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBEAFE),
      body: BlocListener<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationSuccessState) {
            context.goNamed(RouteNames.homepage);
          } else if (state is AuthenticationErrorState) {
            Alerts.of(context).showError(state.error);
          }
        },
        child: Stack(
          children: [
            const AuroraBackground(darkMode: false),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppSizes.gapH16,
                          Center(
                            child: AnimatedTextKit(
                              animatedTexts: [
                                WavyAnimatedText(
                                  'Đăng ký tài khoản',
                                  textStyle: AppTypography.medium26(
                                    color: Colors.black87,
                                  ),
                                  speed: const Duration(milliseconds: 200),
                                ),
                              ],
                              repeatForever: true,
                            ),
                          ),
                          AppSizes.gapH8,
                          Text(
                            'Vui lòng nhập thông tin để tiếp tục',
                            textAlign: TextAlign.center,
                            style: AppTypography.medium16(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          AppSizes.gapH24,
                          const SignUpForm(),

                          AppSizes.gapH24,

                          const AuthDivider(),

                          AppSizes.gapH24,

                          // Google vs Facebook button
                          AuthOauthSection(
                            onGooglePressed: () {
                              context.read<AuthenticationCubit>().signInWithGoogle();
                            },
                            onFacebookPressed: () {
                              context.read<AuthenticationCubit>().signInWithFacebook();
                            },
                          ),

                          AppSizes.gapH32,

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Đã có tài khoản? ",
                                style: AppTypography.medium14(
                                  color: Colors.black54,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Đăng nhập',
                                  style: AppTypography.medium14(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
