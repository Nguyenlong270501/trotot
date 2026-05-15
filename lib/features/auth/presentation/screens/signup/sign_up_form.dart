import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../blocs/auth_blocs/auth_cubit.dart';
import '../../../blocs/auth_blocs/auth_state.dart';
import '../../../blocs/sign_up_form/sign_up_form_cubit.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _UsernameField(),
        AppSizes.gapH20,
        _EmailField(),
        AppSizes.gapH20,
        _PasswordField(),
        AppSizes.gapH20,
        _ConfirmPasswordField(),
        AppSizes.gapH20,
        _SignUpButton(),
      ],
    );
  }
}

class _UsernameField extends StatelessWidget {
  const _UsernameField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpFormCubit, SignUpState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return MyAppTextfield(
          label: 'Tên người dùng',
          hintText: ' Nhập tên của bạn',
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          onChanged: (value) => context.read<SignUpFormCubit>().usernameChanged(value),
          errorText: state.username.displayError != null
              ? "Tên người dùng từ 2 đến 20 ký tự"
              : null,
        );
      },
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpFormCubit, SignUpState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return MyAppTextfield(
          label: 'Email',
          hintText: ' Nhập email của bạn',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (value) => context.read<SignUpFormCubit>().emailChanged(value),
          errorText: state.email.displayError != null ? "Nhập email hợp lệ" : null,
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpFormCubit, SignUpState>(
      buildWhen: (previous, current) => 
          previous.password != current.password ||
          previous.isPasswordObscure != current.isPasswordObscure,
      builder: (context, state) {
        return MyAppTextfield(
          label: 'Mật khẩu',
          hintText: ' Nhập mật khẩu của bạn',
          keyboardType: TextInputType.visiblePassword,
          obscureText: state.isPasswordObscure,
          textInputAction: TextInputAction.done,
          suffixIcon: state.isPasswordObscure ? Icons.visibility_off : Icons.visibility,
          onSuffixIconTap: () => context.read<SignUpFormCubit>().changePasswordObscurity(),
          onChanged: (value) => context.read<SignUpFormCubit>().passwordChanged(value),
          errorText: state.password.displayError != null
              ? "Mật khẩu phải có ít nhất 8 ký tự, 1 chữ hoa và 1 số"
              : null,
        );
      },
    );
  }
}

class _ConfirmPasswordField extends StatelessWidget {
  const _ConfirmPasswordField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpFormCubit, SignUpState>(
      buildWhen: (previous, current) => 
          previous.confirmPassword != current.confirmPassword ||
          previous.isConfirmPasswordObscure != current.isConfirmPasswordObscure ||
          previous.password != current.password, 
      builder: (context, state) {
        return MyAppTextfield(
          label: 'Xác nhận mật khẩu',
          hintText: ' Nhập lại mật khẩu của bạn',
          keyboardType: TextInputType.visiblePassword,
          obscureText: state.isConfirmPasswordObscure,
          textInputAction: TextInputAction.done,
          suffixIcon: state.isConfirmPasswordObscure ? Icons.visibility_off : Icons.visibility,
          onSuffixIconTap: () => context.read<SignUpFormCubit>().changeConfirmPasswordObscurity(),
          onChanged: (value) => context.read<SignUpFormCubit>().confirmPasswordChanged(value),
          errorText: state.confirmPassword.displayError != null 
              ? "Mật khẩu xác nhận không khớp" 
              : null,
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton();

  @override
  Widget build(BuildContext context) {

    final isEnabled = context.select((SignUpFormCubit cubit) => cubit.state.isValid);

    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, state) {
        final isLoading = state is AuthenticationLoadingState;
        return AppButton(
          text: 'Đăng ký',
          isLoading: isLoading,
          isEnabled: isEnabled && !isLoading, 
          onPressed: () {
            if (isEnabled) {
              final formState = context.read<SignUpFormCubit>().state;
              context.read<AuthenticationCubit>().signUpWithEmail(
                formState.email.value,
                formState.password.value,
                formState.username.value,
              );
            }
          },
        );
      },
    );
  }
}