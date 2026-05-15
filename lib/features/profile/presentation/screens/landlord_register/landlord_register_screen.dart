import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../data/repositories/landlord_register_repository.dart';
import '../../../blocs/landlord_register/landlord_register_cubit.dart';
import '../../../blocs/landlord_register/landlord_register_state.dart';
import '../../../data/models/landlord_request.dart';
import 'landlord_register_form.dart';

class LandlordRegisterScreen extends StatelessWidget {
  const LandlordRegisterScreen({super.key, this.existingRequest});

  final LandlordRequest? existingRequest;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LandlordRegisterCubit(
        repository: context.read<LandlordRegisterRepository>(),
        existingRequest: existingRequest,
      ),
      child: BlocListener<LandlordRegisterCubit, LandlordRegisterState>(
        listenWhen: (previous, current) =>
            previous.submitStatus != current.submitStatus,
        listener: (context, state) {
          if (state.submitStatus == FormzSubmissionStatus.success) {
            Alerts.of(context).showSuccess(
              'Đã gửi yêu cầu, đơn của bạn đang được tải lên. Chúng tôi sẽ xem xét và phản hồi sớm.',
            );
            Navigator.of(context).pop();
          } else if (state.submitStatus == FormzSubmissionStatus.failure) {
            Alerts.of(
              context,
            ).showError(state.error ?? 'Có lỗi xảy ra, vui lòng thử lại sau.');
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: AppColors.appBarBackground,
            elevation: 0,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.textSecondary,
              ),
            ),
            centerTitle: true,
            title: existingRequest == null
                ? Text(
                    'Gửi yêu cầu trở thành chủ trọ',
                    style: AppTypography.bold18(color: AppColors.textPrimary),
                  )
                : Text(
                    'Hồ sơ yêu cầu trở thành chủ trọ',
                    style: AppTypography.bold18(color: AppColors.textPrimary),
                  ),
          ),
          body: Container(
            height: MediaQuery.sizeOf(context).height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.profileBodyGradient,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: const LandlordRegisterForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
