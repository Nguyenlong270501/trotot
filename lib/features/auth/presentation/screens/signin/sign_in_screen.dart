import 'package:animate_do/animate_do.dart';
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
import 'sigin_in_form.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        AppSizes.gapH32,
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedTextKit(
                                repeatForever: true,
                                animatedTexts: [
                                  ColorizeAnimatedText(
                                    'Chào mừng bạn\nđến với Trọ Tốt',
                                    textStyle: AppTypography.medium26(
                                      color: Colors.black87,
                                    ),
                                    colors: const [
                                      Colors.black87,
                                      Color(0xFF8B7CFF),
                                      Color(0xFFFFC58F),
                                    ],
                                  ),
                                ],
                              ),
                              FadeInDown(
                                child: SlideInRight(
                                  child: Image.asset(
                                    'assets/icons/app_icon.png',
                                    width: AppSizes.iconSizeXXLarge,
                                    height: AppSizes.iconSizeXXLarge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSizes.gapH32,
                        const SignInForm(),
                        AppSizes.gapH24,

                        const AuthDivider(),
                        AppSizes.gapH24,

                        BlocBuilder<AuthenticationCubit, AuthenticationState>(
                          builder: (context, authState) {
                            final isLoading =
                                authState is AuthenticationLoadingState;
                            return AuthOauthSection(
                              isEnabled: !isLoading,
                              onGooglePressed: () {
                                context
                                    .read<AuthenticationCubit>()
                                    .signInWithGoogle();
                              },
                              onFacebookPressed: () {
                                context
                                    .read<AuthenticationCubit>()
                                    .signInWithFacebook();
                              },
                            );
                          },
                        ),
                        AppSizes.gapH32,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Bạn chưa có tài khoản? ",
                              style: AppTypography.medium14(
                                color: Colors.black54,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.pushNamed(RouteNames.signuppage);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Đăng ký',
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
