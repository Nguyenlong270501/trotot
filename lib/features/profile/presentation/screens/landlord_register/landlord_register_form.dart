import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:formz/formz.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../blocs/landlord_register/landlord_register_cubit.dart';
import '../../../blocs/landlord_register/landlord_register_state.dart';
import 'image_grid_picker.dart';
import 'section_card.dart';

class LandlordRegisterForm extends StatelessWidget {
  const LandlordRegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandlordRegisterCubit, LandlordRegisterState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowSoft,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  state.isReadOnly
                      ? SizedBox.shrink()
                      : Text(
                          'Vui lòng điền thông tin chính xác để được xét duyệt.',
                          style: AppTypography.medium14(
                            color: AppColors.textSecondary,
                          ),
                        ),
                  AppSizes.gapH20,

                  if (state.rejectionReason != '' &&
                      state.rejectionReason != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Hồ sơ bị từ chối: ${state.rejectionReason}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const _FieldLabelWithMark(text: 'Họ và tên'),
                  AppSizes.gapH12,
                  const _LandlordFullNameField(),
                  AppSizes.gapH12,
                  const _FieldLabelWithMark(text: 'Số điện thoại'),
                  AppSizes.gapH8,
                  const _LandlordPhoneField(),
                  AppSizes.gapH6,
                  const _FieldLabelWithMark(text: 'Địa chỉ'),
                  AppSizes.gapH8,
                  const _LandlordAddressField(),
                  AppSizes.gapH12,
                  const _DynamicPropertyQuotasSection(),
                  AppSizes.gapH8,
                ],
              ),
            ),
            AppSizes.gapH24,
            BlocBuilder<LandlordRegisterCubit, LandlordRegisterState>(
              buildWhen: (previous, current) =>
                  previous.cccdFrontPath != current.cccdFrontPath ||
                  previous.cccdBackPath != current.cccdBackPath,
              builder: (context, state) {
                return _CccdSection(state: state);
              },
            ),

            AppSizes.gapH24,

            BlocBuilder<LandlordRegisterCubit, LandlordRegisterState>(
              buildWhen: (previous, current) =>
                  previous.optionalDocPaths != current.optionalDocPaths ||
                  previous.optionalDocUrls != current.optionalDocUrls ||
                  previous.isReadOnly != current.isReadOnly,
              builder: (context, state) {
                final allDocs = [
                  ...state.optionalDocUrls,
                  ...state.optionalDocPaths,
                ];
                return SectionCard(
                  title: 'Giấy tờ chứng minh',
                  subtitle:
                      'Sổ hồng, giấy phép kinh doanh, ... (Có thể chọn nhiều ảnh cùng lúc, tối đa 10 ảnh).',
                  required: true,
                  child: ImageGridPicker(
                    urls: allDocs,
                    maxCount: state.isReadOnly ? allDocs.length : 10,

                    onAdd: state.isReadOnly
                        ? () {}
                        : () => context
                              .read<LandlordRegisterCubit>()
                              .pickOptionalDoc(),

                    onRemoveAt: state.isReadOnly
                        ? (i) {}
                        : (i) => context
                              .read<LandlordRegisterCubit>()
                              .removeOptionalDoc(i),
                  ),
                );
              },
            ),

            AppSizes.gapH32,
            const _SubmitButton(),
            AppSizes.gapH24,
          ],
        );
      },
    );
  }
}

class _LandlordFullNameField extends StatelessWidget {
  const _LandlordFullNameField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandlordRegisterCubit, LandlordRegisterState>(
      buildWhen: (previous, current) => previous.fullName != current.fullName,
      builder: (context, state) {
        return MyAppTextfield(
          label: '',
          showLabel: false,
          hintText: ' Nhập tên của bạn',
          prefixIcon: Icons.person_outline,
          initialValue: state.fullName.value,
          keyboardType: TextInputType.name,
          readOnly: state.isReadOnly,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-ZÀ-ỹ\s]+$')),
          ],
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            context.read<LandlordRegisterCubit>().fullNameChanged(value);
          },
          errorText: state.fullName.displayError != null
              ? "Họ và tên từ 2 đến 100 ký tự"
              : null,
        );
      },
    );
  }
}

class _LandlordPhoneField extends StatelessWidget {
  const _LandlordPhoneField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandlordRegisterCubit, LandlordRegisterState>(
      buildWhen: (previous, current) => previous.phone != current.phone,
      builder: (context, state) {
        return MyAppTextfield(
          label: '',
          showLabel: false,
          hintText: 'Ví dụ: 0987 654 321',
          prefixIcon: Icons.phone_outlined,
          initialValue: state.phone.value,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 10,
          readOnly: state.isReadOnly,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            context.read<LandlordRegisterCubit>().phoneChanged(value);
          },
          errorText: state.phone.displayError != null
              ? "Số điện thoại không hợp lệ (10 số)"
              : null,
        );
      },
    );
  }
}

class _LandlordAddressField extends StatelessWidget {
  const _LandlordAddressField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandlordRegisterCubit, LandlordRegisterState>(
      buildWhen: (previous, current) => previous.address != current.address,
      builder: (context, state) {
        return MyAppTextfield(
          label: '',
          showLabel: false,
          hintText: '123 Đường ABC, Phường XYZ, Hà Nội',
          prefixIcon: Icons.location_on_outlined,
          initialValue: state.address.value,
          keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.done,
          readOnly: state.isReadOnly,
          onChanged: (value) {
            context.read<LandlordRegisterCubit>().addressChanged(value);
          },
          errorText: state.address.displayError != null
              ? "Địa chỉ ít nhất 5 ký tự"
              : null,
        );
      },
    );
  }
}

class _DynamicPropertyQuotasSection extends StatelessWidget {
  const _DynamicPropertyQuotasSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandlordRegisterCubit, LandlordRegisterState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _FieldLabelWithMark(text: 'Số lượng phòng mỗi khu trọ'),
                if (!state.isReadOnly && state.requestedQuotasList.length <= 15)
                  IconButton(
                    onPressed: () =>
                        context.read<LandlordRegisterCubit>().addProperty(),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 250.h),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: state.requestedQuotasList.length,
                itemBuilder: (context, index) {
                  final quota = state.requestedQuotasList[index];

                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h, top: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: MyAppTextfield(
                            label: '',
                            showLabel: false,
                            hintText: 'Số phòng khu ${index + 1}',
                            prefixIcon: Icons.door_front_door_outlined,
                            initialValue: quota.value,
                            keyboardType: TextInputType.number,
                            readOnly: state.isReadOnly,
                            onChanged: (val) => context
                                .read<LandlordRegisterCubit>()
                                .propertyRoomsChanged(index, val),
                            errorText: quota.displayError != null
                                ? "Vui lòng nhập số lượng phòng hợp lệ"
                                : null,
                          ),
                        ),
                        if (!state.isReadOnly &&
                            state.requestedQuotasList.length > 1)
                          IconButton(
                            onPressed: () => context
                                .read<LandlordRegisterCubit>()
                                .removeProperty(index),
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandlordRegisterCubit, LandlordRegisterState>(
      builder: (context, state) {
        final isLoading =
            state.submitStatus == FormzSubmissionStatus.inProgress;
        final isEnabled = state.isFormComplete && state.isChangeMade;
        return AppButton(
          text: state.isEditingExistingRequest
              ? 'Cập nhật yêu cầu'
              : 'Gửi yêu cầu',
          onPressed: isLoading
              ? () {}
              : () => context.read<LandlordRegisterCubit>().submitForm(),
          isLoading: isLoading,
          isEnabled: isEnabled && !isLoading && !state.isReadOnly,
        );
      },
    );
  }
}

class _FieldLabelWithMark extends StatelessWidget {
  const _FieldLabelWithMark({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: AppTypography.medium14(color: AppColors.textPrimary),
        children: [
          TextSpan(text: '$text '),
          TextSpan(
            text: '(*)',
            style: AppTypography.medium14(color: AppColors.requiredMark),
          ),
        ],
      ),
    );
  }
}

class _CccdSection extends StatelessWidget {
  const _CccdSection({required this.state});

  final LandlordRegisterState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppTypography.bold16(color: AppColors.textPrimary),
                    children: [
                      const TextSpan(text: 'Ảnh căn cước công dân '),
                      TextSpan(
                        text: '(*)',
                        style: AppTypography.medium16(
                          color: AppColors.requiredMark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AppSizes.gapH4,
          Text(
            'Tải đủ mặt trước và mặt sau.',
            style: AppTypography.medium12(color: AppColors.textSecondary),
          ),
          AppSizes.gapH12,
          Row(
            children: [
              Expanded(
                child: _CccdPickTile(
                  sideLabel: 'Mặt trước',
                  localPath: state.cccdFrontPath,
                  cccdFromUrl: state.cccdFrontUrl,
                  onTap: state.isReadOnly
                      ? () {}
                      : () => context
                            .read<LandlordRegisterCubit>()
                            .pickCccdFront(),
                ),
              ),
              AppSizes.gapW12,
              Expanded(
                child: _CccdPickTile(
                  sideLabel: 'Mặt sau',
                  localPath: state.cccdBackPath,
                  cccdFromUrl: state.cccdBackUrl,
                  onTap: state.isReadOnly
                      ? () {}
                      : () => context
                            .read<LandlordRegisterCubit>()
                            .pickCccdBack(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CccdPickTile extends StatelessWidget {
  const _CccdPickTile({
    required this.sideLabel,
    required this.localPath,
    required this.onTap,
    required this.cccdFromUrl,
  });

  final String sideLabel;
  final String? localPath;
  final String? cccdFromUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = localPath != null && localPath!.isNotEmpty;
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: AspectRatio(
          aspectRatio: 1.15,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  Image.file(File(localPath!), fit: BoxFit.cover)
                else if (cccdFromUrl != null)
                  Image.network(cccdFromUrl!)
                else
                  ColoredBox(
                    color: AppColors.surfaceCard.withValues(alpha: 0.65),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: AppSizes.iconSizeMedium,
                          color: AppColors.accentIcon,
                        ),
                        AppSizes.gapH8,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Text(
                            'Chạm để tải ảnh',
                            textAlign: TextAlign.center,
                            style: AppTypography.medium12(
                              color: AppColors.accentDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Positioned(
                  left: 8.w,
                  top: 8.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text.rich(
                      TextSpan(
                        style: AppTypography.bold10(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(text: '$sideLabel '),
                          TextSpan(
                            text: '(*)',
                            style: AppTypography.bold10(
                              color: AppColors.requiredMark.withValues(
                                alpha: 0.95,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
