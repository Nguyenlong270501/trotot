import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_enums.dart';
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
    if (!await _ensureAccountActive(user)) {
      return;
    }

    emit(AuthenticationSuccessState(user));
    _listenToUser(user.userId);

    final userId = user.userId.trim();
    if (userId.isEmpty) return;

    try {
      await FCMService().requestNotificationPermission(uid: userId);
    } catch (e, st) {
      log('Yêu cầu quyền thông báo thất bại: $e', error: e, stackTrace: st);
    }
  }

  Future<bool> _ensureAccountActive(UserModel user) async {
    if (user.status == UserStatus.active) {
      return true;
    }

    await _rejectInactiveAccount(user);
    return false;
  }

  Future<void> _rejectInactiveAccount(UserModel user) async {
    await _userSubscription?.cancel();
    _userSubscription = null;

    final userId = user.userId.trim();
    if (userId.isNotEmpty) {
      try {
        await FCMService().clearUserFcmTokensOnFirestore(userId);
      } catch (e) {
        log(
          'Xóa token FCM trên Firestore thất bại cho tài khoản không hoạt động: $e',
        );
      }
    }

    try {
      await _authRepository.signOut();
    } catch (e) {
      log('Đăng xuất từ Firebase thất bại cho tài khoản không hoạt động: $e');
    }

    try {
      await FCMService().deleteLocalMessagingToken();
    } catch (e) {
      log('Xóa token thông báo cục bộ thất bại: $e');
    }

    emit(
      AuthenticationErrorState(
        'Tài khoản của bạn đã bị khóa, vui lòng liên hệ quản trị viên để được hỗ trợ.',
      ),
    );
  }

  void _listenToUser(String userId) {
    _userSubscription?.cancel();
    _userSubscription = _authRepository
        .watchCurrentUserData(userId)
        .listen(
          (user) async {
            if (user != null) {
              if (!await _ensureAccountActive(user)) {
                return;
              }
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
    final currentUser = state is AuthenticationSuccessState
        ? (state as AuthenticationSuccessState).user
        : null;
    final userId = currentUser?.userId.trim();

    try {
      emit(AuthenticationLoadingState());

      if (userId != null && userId.isNotEmpty) {
        try {
          await FCMService().clearUserFcmTokensOnFirestore(userId);
        } catch (e) {
          log('⚠️ Xóa token FCM trên Firestore thất bại: $e');
        }
      }

      await _authRepository.signOut();

      try {
        await FCMService().deleteLocalMessagingToken();
      } catch (e) {
        log('⚠️ Xóa token thông báo cục bộ thất bại: $e');
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
        if (!await _ensureAccountActive(updatedUser)) {
          return;
        }
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
