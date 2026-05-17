import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/fcm_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user.dart';
import 'auth_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthenticationInitial());

  final AuthRepository _authRepository;
  StreamSubscription<UserModel?>? _userSubscription;

  Future<void> _onAuthSuccess(UserModel user) async {
    emit(AuthenticationSuccessState(user));
    _listenToUser(user.userId);

    final userId = user.userId.trim();
    if (userId.isEmpty) return;

    try {
      await FCMService().requestNotificationPermission(uid: userId);
    } catch (e, st) {
      log(
        'FCM permission/sync failed after auth success',
        error: e,
        stackTrace: st,
      );
    }
  }

  void _listenToUser(String userId) {
    _userSubscription?.cancel();
    _userSubscription = _authRepository
        .watchCurrentUserData(userId)
        .listen(
          (user) {
            if (user != null) {
              emit(AuthenticationSuccessState(user));
            } else {
              emit(UnAuthenticationState());
            }
          },
          onError: (error) {
            log('Lỗi khi lắng nghe user data: $error');
            emit(UnAuthenticationState());
          },
        );
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      emit(AuthenticationLoadingState());
      final result = await _authRepository.loginWithEmail(email, password);
      await result.fold(
        (failure) async {
          emit(AuthenticationErrorState(failure));
        },
        (user) async {
          await _onAuthSuccess(user);
        },
      );
    } catch (e) {
      emit(AuthenticationErrorState(e.toString()));
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String userName,
  ) async {
    try {
      emit(AuthenticationLoadingState());
      final result = await _authRepository.signUpWithEmail(
        email,
        password,
        userName,
      );
      await result.fold(
        (failure) async {
          emit(AuthenticationErrorState(failure));
        },
        (user) async {
          await _onAuthSuccess(user);
        },
      );
    } catch (e) {
      emit(AuthenticationErrorState(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthenticationLoadingState());
      final result = await _authRepository.signInWithGoogle();
      await result.fold(
        (error) async {
          emit(AuthenticationErrorState(error));
        },
        (user) async {
          await _onAuthSuccess(user);
        },
      );
    } catch (e) {
      emit(AuthenticationErrorState(e.toString()));
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      emit(AuthenticationLoadingState());
      final result = await _authRepository.signInWithFacebook();
      await result.fold(
        (error) async {
          emit(AuthenticationErrorState(error));
        },
        (user) async {
          await _onAuthSuccess(user);
        },
      );
    } catch (e) {
      emit(AuthenticationErrorState(e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      emit(AuthenticationLoadingState());
      final result = await _authRepository.sendPasswordResetEmail(email);
      result.fold(
        (error) => emit(AuthenticationErrorState(error)),
        (_) => emit(
          PasswordResetEmailSentState(
            'Đã gửi email đặt lại mật khẩu. Vui lòng kiểm tra hộp thư của bạn.',
          ),
        ),
      );
    } catch (e) {
      emit(AuthenticationErrorState(e.toString()));
    }
  }

  Future<void> signout() async {
    // Lấy userId TRƯỚC khi đổi state, tránh mất reference
    final currentUser = state is AuthenticationSuccessState
        ? (state as AuthenticationSuccessState).user
        : null;
    final userId = currentUser?.userId.trim();

    try {
      emit(AuthenticationLoadingState());

      // 1. Clear token trên Firestore trước (best-effort, không block logout)
      if (userId != null && userId.isNotEmpty) {
        try {
          await FCMService().clearUserFcmTokensOnFirestore(userId);
        } catch (e) {
          log('⚠️ clearUserFcmTokensOnFirestore failed, continuing logout: $e');
        }
      }

      // 2. Logout Firebase Auth
      await _authRepository.signOut();

      // 3. Xóa local token sau logout (best-effort)
      try {
        await FCMService().deleteLocalMessagingToken();
      } catch (e) {
        log('⚠️ deleteLocalMessagingToken failed, ignored: $e');
      }

      await _userSubscription?.cancel();
      _userSubscription = null;

      emit(UnAuthenticationState());
    } catch (e) {
      emit(AuthenticationErrorState(e.toString()));
    }
  }

  Future<void> reloadUserData() async {
    try {
      final updatedUser = await _authRepository.getCurrentUser();

      if (updatedUser != null) {
        emit(AuthenticationSuccessState(updatedUser));
        if (_userSubscription == null) {
          _listenToUser(updatedUser.userId);
        }
      }
    } catch (e) {
      log('Lỗi khi reload user: $e');
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        await _onAuthSuccess(user);
      } else {
        emit(UnAuthenticationState());
      }
    } catch (e) {
      emit(UnAuthenticationState());
    }
  }
}
