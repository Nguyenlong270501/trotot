import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/property_helper.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../blocs/appointment_create/appointment_create_cubit.dart';
import '../../blocs/appointment_create/appointment_create_state.dart';
import '../../blocs/appointment_form/appointment_form_cubit.dart';
import '../../blocs/appointment_form/appointment_form_state.dart';
import '../../../auth/blocs/auth_blocs/auth_cubit.dart';
import '../../../auth/blocs/auth_blocs/auth_state.dart';
import '../../../auth/data/models/user.dart';
import '../../../home/data/models/property_model.dart';
import '../../../home/data/models/room_model.dart';
import '../widgets/appointment_bottom_bar.dart';
import '../widgets/appointment_cancel_reasons_section.dart';
import '../widgets/appointment_calendar.dart';
import '../widgets/appointment_header.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/booking_purpose.dart';
import '../widgets/appointment_note_field.dart';
import '../widgets/appointment_phone_field.dart';
import '../widgets/appointment_property_brief_card.dart';
import '../widgets/appointment_purpose_grid.dart';
import '../widgets/appointment_section.dart';
import '../widgets/appointment_summary_box.dart';
import '../widgets/appointment_time_slots.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({
    super.key,
    required this.property,
    required this.rooms,
    this.initialAppointment,
  });

  final PropertyModel property;
  final List<RoomModel> rooms;
  final AppointmentModel? initialAppointment;

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

enum _RescheduleResponse { accept, reject, cancelAccepted }

class _AppointmentScreenState extends State<AppointmentScreen> {
  UserModel? _currentUser;
  _RescheduleResponse? _rescheduleResponse;

  final List<BookingPurpose> purposes = const [
    BookingPurpose(label: 'Xem lần đầu', icon: Icons.search_rounded),
    BookingPurpose(label: 'Kiểm tra hợp đồng', icon: Icons.description_rounded),
    BookingPurpose(label: 'Kiểm tra cơ sở vật chất', icon: Icons.build_rounded),
    BookingPurpose(label: 'Thương lượng giá', icon: Icons.chat_bubble_rounded),
  ];

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthenticationCubit>().state;
    if (authState is AuthenticationSuccessState) {
      _currentUser = authState.user;
      final phone = (_currentUser!.phoneNumber ?? '').trim();
      if (phone.isNotEmpty) {
        _phoneController.text = phone;
      }
      context.read<AppointmentFormCubit>().setTenantPhone(
        _phoneController.text,
      );
    }

    final initial = widget.initialAppointment;
    if (initial != null && initial.appointmentId.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        context.read<AppointmentCreateCubit>().setExistingAppointment(initial);
        _hydrateFormFromAppointment(initial);
      });
    }
  }

  void _hydrateFormFromAppointment(AppointmentModel appointment) {
    final purposeLabels = purposes.map((p) => p.label).toList();
    context.read<AppointmentFormCubit>().hydrateFromAppointment(
      appointment,
      purposeLabels: purposeLabels,
    );
    _phoneController.text = appointment.tenantPhone;
    _noteController.text = appointment.note;
  }

  List<String> get _purposeLabels => purposes.map((p) => p.label).toList();

  @override
  void dispose() {
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(AppointmentFormState formState) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: formState.selectedDate.isBefore(now)
          ? now
          : formState.selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null && mounted) {
      context.read<AppointmentFormCubit>().setSelectedDate(picked);
    }
  }

  Future<void> _pickTime(AppointmentFormState formState) async {
    DateTime draft = DateTime(
      formState.selectedDate.year,
      formState.selectedDate.month,
      formState.selectedDate.day,
      formState.selectedTime.hour,
      formState.selectedTime.minute,
    );
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => _PickerSheet(
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          initialDateTime: draft,
          onDateTimeChanged: (value) => draft = value,
        ),
        onDone: () {
          context.read<AppointmentFormCubit>().setSelectedTime(
            TimeOfDay(hour: draft.hour, minute: draft.minute),
          );
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  Future<bool> _confirmSubmit({required bool isUpdate}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isUpdate ? 'Cập nhật lịch hẹn' : 'Xác nhận đặt lịch'),
          content: Text(
            isUpdate
                ? 'Bạn có muốn cập nhật lịch hẹn này không?'
                : 'Bạn có muốn đặt lịch hẹn này không?',
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => dialogContext.pop(true),
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<bool> _confirmAcceptReschedule() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Đồng ý lịch hẹn'),
          content: const Text('Bạn có đồng ý lịch hẹn mới không?'),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => dialogContext.pop(true),
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<String?> _showRejectReasonDialog() {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => const _RejectReasonDialog(),
    );
  }

  Future<String?> _showCancelReasonDialog() {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => const _CancelReasonDialog(),
    );
  }

  String _successMessageForCreateState(AppointmentCreateState createState) {
    if (_rescheduleResponse == _RescheduleResponse.accept) {
      return 'Đã đồng ý lịch hẹn mới';
    }
    if (_rescheduleResponse == _RescheduleResponse.reject) {
      return 'Đã từ chối lịch hẹn';
    }
    if (_rescheduleResponse == _RescheduleResponse.cancelAccepted) {
      return 'Đã hủy lịch hẹn';
    }
    if (createState.lastOperationWasUpdate) {
      return 'Đã cập nhật lịch hẹn thành công';
    }
    return 'Đã tạo lịch hẹn thành công';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentCreateCubit, AppointmentCreateState>(
      listenWhen: (previous, current) =>
          previous.isSuccess != current.isSuccess ||
          previous.errorMessage != current.errorMessage,
      listener: (context, createState) {
        if (createState.errorMessage != null &&
            createState.errorMessage!.isNotEmpty) {
          Alerts.of(context).showError(createState.errorMessage!);
          context.read<AppointmentCreateCubit>().clearFeedback();
          return;
        }
        if (createState.isSuccess) {
          Alerts.of(
            context,
          ).showSuccess(_successMessageForCreateState(createState));
          _rescheduleResponse = null;
          final formCubit = context.read<AppointmentFormCubit>();
          formCubit.showConfirmedSuccess();
          final saved = createState.existingAppointment;
          if (saved != null) {
            formCubit.syncBaselineFromAppointment(saved);
            _noteController.text = saved.note;
            _phoneController.text = saved.tenantPhone;
          }
          Future<void>.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              context.read<AppointmentFormCubit>().hideConfirmedSuccess();
            }
          });
          context.read<AppointmentCreateCubit>().clearFeedback();
        }
      },
      builder: (context, createState) {
        final user = _currentUser;
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Đặt lịch hẹn')),
            body: const Center(
              child: Text('Vui lòng đăng nhập để đặt lịch hẹn.'),
            ),
          );
        }

        final isOwnProperty =
            user.userId.trim() == widget.property.landlordId.trim();
        if (isOwnProperty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Đặt lịch hẹn')),
            body: const Center(
              child: Text(
                'Bạn không thể đặt lịch xem phòng trên bài đăng của chính mình.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return BlocBuilder<AppointmentFormCubit, AppointmentFormState>(
          builder: (context, formState) {
            final appointment =
                createState.existingAppointment ?? widget.initialAppointment;
            final isRescheduled =
                appointment?.status == AppointmentStatus.rescheduled;
            final isAccepted =
                appointment?.status == AppointmentStatus.accepted;
            final isTenantResponder =
                isRescheduled &&
                appointment != null &&
                user.userId.trim() == appointment.tenantId.trim();
            final isFormLocked = isRescheduled || isAccepted;

            return Scaffold(
              backgroundColor: AppColors.scaffoldBackground,
              body: Column(
                children: [
                  AppointmentHeader(onBackTap: () => context.pop()),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Opacity(
                        opacity: isFormLocked ? 0.65 : 1,
                        child: AbsorbPointer(
                          absorbing: isFormLocked,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppSizes.gapH16,
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: AppointmentPropertyBriefCard(
                                  property: widget.property,
                                ),
                              ),
                              AppSizes.gapH16,
                              AppointmentSection(
                                label: 'Chọn ngày',
                                child: AppointmentCalendar(
                                  selectedDate: formState.selectedDate,
                                  onPickDate: () => _pickDate(formState),
                                ),
                              ),
                              const AppointmentDivider(),
                              AppointmentSection(
                                label: 'Chọn khung giờ',
                                child: AppointmentTimeSlots(
                                  selectedTimeLabel: formState.formattedTime,
                                  onPickTime: () => _pickTime(formState),
                                ),
                              ),
                              const AppointmentDivider(),
                              AppointmentSection(
                                label: 'Mục đích xem phòng',
                                child: AppointmentPurposeGrid(
                                  purposes: purposes,
                                  selectedPurpose: formState.selectedPurpose,
                                  onSelectPurpose: context
                                      .read<AppointmentFormCubit>()
                                      .setSelectedPurpose,
                                ),
                              ),
                              const AppointmentDivider(),
                              AppointmentSection(
                                label: 'Số điện thoại liên hệ',
                                child: AppointmentPhoneField(
                                  controller: _phoneController,
                                  hintText:
                                      'Vui lòng nhập sdt để chủ trọ liên hệ (nếu cần)',
                                  onChanged: context
                                      .read<AppointmentFormCubit>()
                                      .setTenantPhone,
                                ),
                              ),
                              const AppointmentDivider(),
                              AppointmentSection(
                                label: 'Ghi chú thêm',
                                child: AppointmentNoteField(
                                  controller: _noteController,
                                  onChanged: context
                                      .read<AppointmentFormCubit>()
                                      .setNote,
                                ),
                              ),
                              AppointmentSummaryBox(
                                dayName: formState.dayName,
                                selectedDate: formState.selectedDate,
                                formattedTime: formState.formattedTime,
                                bookerName: user.userName,
                                bookerPhone: formState.tenantPhone,
                                landlordName:
                                    widget.property.landlordSummary?.userName ??
                                    'Chủ trọ',
                                landlordPhone:
                                    widget
                                        .property
                                        .landlordSummary
                                        ?.phoneNumber ??
                                    '—',
                              ),
                              if (appointment != null)
                                AppointmentCancelReasonsSection(
                                  landlordCancelReason:
                                      appointment.landlordCancelReason,
                                  tenantCancelReason:
                                      appointment.tenantCancelReason,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: AppointmentBottomBar(
                confirmed: formState.confirmed,
                isLoading: createState.isLoading,
                isUpdateMode: createState.isUpdateMode,
                showRescheduleResponse: isTenantResponder,
                showCancelAction: isAccepted,
                isSubmitEnabled:
                    !isFormLocked &&
                    (!createState.isUpdateMode ||
                        formState.hasUnsavedChanges(_purposeLabels)),
                successLabel: createState.lastOperationWasUpdate
                    ? '✓  Đã cập nhật lịch hẹn!'
                    : '✓  Đã đặt lịch thành công!',
                onMessageTap: () {},
                onAcceptRescheduleTap: () async {
                  if (appointment == null) {
                    return;
                  }
                  final confirmed = await _confirmAcceptReschedule();
                  if (!confirmed || !context.mounted) {
                    return;
                  }
                  _rescheduleResponse = _RescheduleResponse.accept;
                  await context
                      .read<AppointmentCreateCubit>()
                      .acceptRescheduled(appointment: appointment);
                },
                onRejectRescheduleTap: () async {
                  if (appointment == null) {
                    return;
                  }
                  final reason = await _showRejectReasonDialog();
                  if (reason == null || !context.mounted) {
                    return;
                  }
                  _rescheduleResponse = _RescheduleResponse.reject;
                  await context
                      .read<AppointmentCreateCubit>()
                      .rejectRescheduled(
                        appointment: appointment,
                        reason: reason,
                      );
                },
                onCancelTap: () async {
                  if (appointment == null) {
                    return;
                  }
                  final reason = await _showCancelReasonDialog();
                  if (reason == null || !context.mounted) {
                    return;
                  }
                  _rescheduleResponse = _RescheduleResponse.cancelAccepted;
                  await context.read<AppointmentCreateCubit>().cancelAccepted(
                    appointment: appointment,
                    reason: reason,
                  );
                },
                onConfirmTap: () async {
                  if (isFormLocked) {
                    return;
                  }
                  final isUpdate = createState.isUpdateMode;
                  final confirmed = await _confirmSubmit(isUpdate: isUpdate);
                  if (!confirmed || !context.mounted) {
                    return;
                  }
                  final purpose = purposes[formState.selectedPurpose].label;
                  final createCubit = context.read<AppointmentCreateCubit>();
                  if (isUpdate) {
                    final existing = createState.existingAppointment!;
                    // Khi Tenant chủ động cập nhật lại lịch hẹn (VD: xin dời ngày khác),
                    // trạng thái sẽ trở về pending để Chủ trọ nhận được và duyệt lại.
                    const newStatus = AppointmentStatus.pending;
                    await createCubit.updateAppointment(
                      appointment: existing.copyWith(
                        appointmentDate: formState.appointmentDateTime,
                        purpose: purpose,
                        note: formState.note.trim(),
                        tenantPhone: formState.tenantPhone,
                        tenantName: user.userName,
                        propertyTitle: widget.property.title,
                        propertyAddress:
                            PropertyHelper.propertyLocationSubtitle(
                              widget.property,
                            ),
                        status: newStatus,
                      ),
                    );
                    return;
                  }
                  await createCubit.createAppointment(
                    propertyId: widget.property.propertyId,
                    tenantId: user.userId,
                    landlordId: widget.property.landlordId,
                    appointmentDate: formState.appointmentDateTime,
                    purpose: purpose,
                    note: _noteController.text,
                    propertyTitle: widget.property.title,
                    propertyAddress: PropertyHelper.propertyLocationSubtitle(
                      widget.property,
                    ),
                    tenantName: user.userName,
                    tenantPhone: formState.tenantPhone,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _RejectReasonDialog extends StatefulWidget {
  const _RejectReasonDialog();

  @override
  State<_RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<_RejectReasonDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _canSubmit = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: const Text(
        'Từ chối lịch hẹn',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lý do từ chối sẽ được gửi đến Chủ trọ.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _controller,
            maxLength: 200,
            maxLines: 3,
            autofocus: true,
            onChanged: (value) {
              setState(() => _canSubmit = value.trim().isNotEmpty);
            },
            decoration: InputDecoration(
              hintText: 'Nhập lý do tại đây...',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
        ),
        FilledButton(
          onPressed: _canSubmit
              ? () => context.pop(_controller.text.trim())
              : null,
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}

class _CancelReasonDialog extends StatefulWidget {
  const _CancelReasonDialog();

  @override
  State<_CancelReasonDialog> createState() => _CancelReasonDialogState();
}

class _CancelReasonDialogState extends State<_CancelReasonDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _canSubmit = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: const Text(
        'Hủy lịch hẹn',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lý do hủy lịch sẽ được gửi đến Chủ trọ.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _controller,
            maxLength: 200,
            maxLines: 3,
            autofocus: true,
            onChanged: (value) {
              setState(() => _canSubmit = value.trim().isNotEmpty);
            },
            decoration: InputDecoration(
              hintText: 'Nhập lý do hủy lịch...',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text('Đóng', style: TextStyle(color: Colors.grey[600])),
        ),
        FilledButton(
          onPressed: _canSubmit
              ? () => context.pop(_controller.text.trim())
              : null,
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({required this.child, required this.onDone});

  final Widget child;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      color: Colors.white,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: CupertinoButton(
              onPressed: () {
                onDone();
              },
              child: const Text('Xong'),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
