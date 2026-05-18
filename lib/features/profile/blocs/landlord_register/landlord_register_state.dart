import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../../../../core/value_objects/address_line.dart';
import '../../../../core/value_objects/full_name.dart';
import '../../../../core/value_objects/vietnam_phone.dart';
import '../../../../core/value_objects/requested_quotas.dart';

class LandlordRegisterState extends Equatable {
  const LandlordRegisterState({
    this.fullName = const FullName.pure(),
    this.phone = const VietnamPhone.pure(),
    this.address = const AddressLine.pure(),
    this.requestedQuotasList = const [RequestedQuotas.pure()],
    this.cccdFrontPath,
    this.cccdBackPath,
    this.optionalDocPaths = const [],
    this.submitStatus = FormzSubmissionStatus.initial,
    this.error,
    this.isValid = false,
    this.isChangeMade = false,
    this.isReadOnly = false,
    this.rejectionReason,
    this.cccdFrontUrl,
    this.cccdBackUrl,
    this.optionalDocUrls = const [],
  });

  final FullName fullName;
  final VietnamPhone phone;
  final AddressLine address;
  final List<RequestedQuotas> requestedQuotasList;
  final String? cccdFrontPath;
  final String? cccdBackPath;
  final List<String> optionalDocPaths;
  final FormzSubmissionStatus submitStatus;
  final String? error;
  final bool isValid;
  final bool isChangeMade;
  final bool isReadOnly;
  final String? rejectionReason;
  final String? cccdFrontUrl;
  final String? cccdBackUrl;
  final List<String> optionalDocUrls;

  bool get isTextFormValid =>
      Formz.validate([fullName, phone, address, ...requestedQuotasList]);

  bool get isFormComplete =>
      isValid &&
      (cccdFrontPath != null || cccdFrontUrl != null) &&
      (cccdBackPath != null || cccdBackUrl != null) &&
      (optionalDocPaths.isNotEmpty || optionalDocUrls.isNotEmpty);

  bool get isEditingExistingRequest =>
      cccdFrontUrl != null || cccdBackUrl != null;

  LandlordRegisterState copyWith({
    FullName? fullName,
    VietnamPhone? phone,
    AddressLine? address,
    List<RequestedQuotas>? requestedQuotasList,
    String? cccdFrontPath,
    String? cccdBackPath,
    List<String>? optionalDocPaths,
    FormzSubmissionStatus? submitStatus,
    String? error,
    bool? isValid,
    bool clearCccdFront = false,
    bool clearCccdBack = false,
    bool clearError = false,
    bool? isReadOnly,
    bool? isChangeMade,
    String? rejectionReason,
    String? cccdFrontUrl,
    String? cccdBackUrl,
    List<String>? optionalDocUrls,
  }) {
    return LandlordRegisterState(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      requestedQuotasList: requestedQuotasList ?? this.requestedQuotasList,
      cccdFrontPath: clearCccdFront
          ? null
          : (cccdFrontPath ?? this.cccdFrontPath),
      cccdBackPath: clearCccdBack ? null : (cccdBackPath ?? this.cccdBackPath),
      optionalDocPaths: optionalDocPaths ?? this.optionalDocPaths,
      submitStatus: submitStatus ?? this.submitStatus,
      error: clearError ? null : (error ?? this.error),
      isValid: isValid ?? this.isValid,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      cccdFrontUrl: cccdFrontUrl ?? this.cccdFrontUrl,
      cccdBackUrl: cccdBackUrl ?? this.cccdBackUrl,
      optionalDocUrls: optionalDocUrls ?? this.optionalDocUrls,
      isChangeMade: isChangeMade ?? this.isChangeMade,
    );
  }

  @override
  List<Object?> get props => [
    fullName,
    phone,
    address,
    requestedQuotasList,
    cccdFrontPath,
    cccdBackPath,
    optionalDocPaths,
    submitStatus,
    error,
    isValid,
    isChangeMade,
    isReadOnly,
    rejectionReason,
    cccdFrontUrl,
    cccdBackUrl,
    optionalDocUrls,
  ];
}
