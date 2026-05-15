part of 'sign_up_form_cubit.dart';

final class SignUpState extends Equatable {
  const SignUpState({
    this.status = FormzSubmissionStatus.initial,
    this.username = const Username.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
    this.isValid = false,
    this.isPasswordObscure = true,
    this.isConfirmPasswordObscure = true,
    this.error,
  });

  final FormzSubmissionStatus status;
  final Email email;
  final Password password;
  final ConfirmPassword confirmPassword;
  final Username username;
  final bool isValid;
  final bool isPasswordObscure;
  final bool isConfirmPasswordObscure;
  final String? error;

  SignUpState copyWith({
    FormzSubmissionStatus? status,
    Email? email,
    Password? password,
    ConfirmPassword? confirmPassword,
    Username? username,
    bool? isValid,
    bool? isPasswordObscure,
    bool? isConfirmPasswordObscure,
    String? error,
  }) {
    return SignUpState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      username: username ?? this.username,
      isValid: isValid ?? this.isValid,
      isPasswordObscure: isPasswordObscure ?? this.isPasswordObscure,
      isConfirmPasswordObscure: isConfirmPasswordObscure ?? this.isConfirmPasswordObscure,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        email,
        password,
        confirmPassword,
        username,
        isValid,
        isPasswordObscure,
        isConfirmPasswordObscure,
        error,
      ];
}