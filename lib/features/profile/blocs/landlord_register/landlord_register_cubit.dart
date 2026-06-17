import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../../core/services/landlord_upload_worker.dart';
import '../../../../core/value_objects/address_line.dart';
import '../../../../core/value_objects/full_name.dart';
import '../../../../core/value_objects/vietnam_phone.dart';
import '../../../../core/value_objects/requested_quotas.dart';
import '../../data/models/landlord_request.dart';
import '../../data/repositories/landlord_register_repository.dart';
import 'landlord_register_state.dart';

class LandlordRegisterCubit extends Cubit<LandlordRegisterState> {
  final LandlordRegisterRepository _repository;

  LandlordRegisterCubit({
    required LandlordRegisterRepository repository,
    LandlordRequest? existingRequest,
  }) : _repository = repository,
       super(_initializeState(existingRequest));

  static LandlordRegisterState _initializeState(LandlordRequest? request) {
    if (request == null) {
      return const LandlordRegisterState();
    }

    final fullName = FullName.dirty(request.fullName);
    final phone = VietnamPhone.dirty(request.phone);
    final address = AddressLine.dirty(request.address);

    final List<RequestedQuotas> quotasList = (request.numOfRoomsList.isNotEmpty)
        ? request.numOfRoomsList
              .map((rooms) => RequestedQuotas.dirty(rooms.toString()))
              .toList()
        : [const RequestedQuotas.pure()];

    return LandlordRegisterState(
      fullName: fullName,
      phone: phone,
      address: address,
      requestedQuotasList: quotasList,
      isValid: Formz.validate([fullName, phone, address, ...quotasList]),
      isReadOnly: request.status == LandlordRequestStatus.approved,
      rejectionReason: request.rejectionReason,
      cccdFrontUrl: request.cccdFrontUrl,
      cccdBackUrl: request.cccdBackUrl,
      optionalDocUrls: request.optionalDocumentUrls,
    );
  }

  void markAsChanged() {
    if (!state.isChangeMade) {
      emit(state.copyWith(isChangeMade: true));
    }
  }

  void fullNameChanged(String value) {
    markAsChanged();
    final fullName = FullName.dirty(value);
    emit(
      state.copyWith(
        fullName: fullName,
        isValid: Formz.validate([
          fullName,
          state.phone,
          state.address,
          ...state.requestedQuotasList,
        ]),
        clearError: true,
        error: null,
      ),
    );
  }

  void phoneChanged(String value) {
    markAsChanged();
    final phone = VietnamPhone.dirty(value);
    emit(
      state.copyWith(
        phone: phone,
        isValid: Formz.validate([
          state.fullName,
          phone,
          state.address,
          ...state.requestedQuotasList,
        ]),
        clearError: true,
        error: null,
      ),
    );
  }

  void addressChanged(String value) {
    markAsChanged();
    final address = AddressLine.dirty(value);
    emit(
      state.copyWith(
        address: address,
        isValid: Formz.validate([
          state.fullName,
          state.phone,
          address,
          ...state.requestedQuotasList,
        ]),
        clearError: true,
        error: null,
      ),
    );
  }

  void addProperty() {
    if (state.isReadOnly) return;

    if (state.requestedQuotasList.length >= 20) {
      emit(state.copyWith(error: 'Bạn chỉ được đăng ký tối đa 20 khu trọ.'));
      return;
    }

    markAsChanged();
    final newList = [
      ...state.requestedQuotasList,
      const RequestedQuotas.pure(),
    ];
    emit(
      state.copyWith(
        requestedQuotasList: newList,
        isValid: Formz.validate([
          state.fullName,
          state.phone,
          state.address,
          ...newList,
        ]),
      ),
    );
  }

  void removeProperty(int index) {
    if (state.isReadOnly || state.requestedQuotasList.length <= 1) return;
    markAsChanged();
    final newList = [...state.requestedQuotasList]..removeAt(index);
    emit(
      state.copyWith(
        requestedQuotasList: newList,
        isValid: Formz.validate([
          state.fullName,
          state.phone,
          state.address,
          ...newList,
        ]),
      ),
    );
  }

  void propertyRoomsChanged(int index, String value) {
    markAsChanged();
    final newList = [...state.requestedQuotasList];
    newList[index] = RequestedQuotas.dirty(value);
    emit(
      state.copyWith(
        requestedQuotasList: newList,
        isValid: Formz.validate([
          state.fullName,
          state.phone,
          state.address,
          ...newList,
        ]),
        clearError: true,
        error: null,
      ),
    );
  }

  Future<void> pickCccdFront() async {
    if (state.isReadOnly) return;
    try {
      final xFile = await _repository.pickImageFromGallery();
      if (xFile != null) {
        cccdFrontChanged(xFile.path);
      }
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi chọn ảnh mặt trước: ${e.toString()}'));
    }
  }

  void cccdFrontChanged(String path) {
    markAsChanged();
    emit(state.copyWith(cccdFrontPath: path, clearError: true));
  }

  void removeCccdFront() {
    if (state.isReadOnly) return;
    markAsChanged();
    emit(state.copyWith(clearCccdFront: true));
  }

  Future<void> pickCccdBack() async {
    if (state.isReadOnly) return;
    try {
      final xFile = await _repository.pickImageFromGallery();
      if (xFile != null) {
        cccdBackChanged(xFile.path);
      }
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi chọn ảnh mặt sau: ${e.toString()}'));
    }
  }

  void cccdBackChanged(String path) {
    markAsChanged();
    emit(state.copyWith(cccdBackPath: path, clearError: true));
  }

  void removeCccdBack() {
    if (state.isReadOnly) return;
    markAsChanged();
    emit(state.copyWith(clearCccdBack: true));
  }

  Future<void> pickOptionalDoc() async {
    if (state.isReadOnly) return;
    if (state.optionalDocPaths.length >= 10) return;

    try {
      final xFiles = await _repository.pickMultipleImages();
      if (xFiles.isNotEmpty) {
        final newPaths = xFiles.map((f) => f.path).toList();
        final nextPaths = [...state.optionalDocPaths, ...newPaths];
        final finalPaths = nextPaths.length > 10
            ? nextPaths.sublist(0, 10)
            : nextPaths;

        markAsChanged();
        emit(state.copyWith(optionalDocPaths: finalPaths, clearError: true));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi chọn giấy tờ phụ: ${e.toString()}'));
    }
  }

  void removeOptionalDoc(int index) {
    if (state.isReadOnly) return;

    final totalCount =
        state.optionalDocUrls.length + state.optionalDocPaths.length;
    if (index < 0 || index >= totalCount) return;

    markAsChanged();

    if (index < state.optionalDocUrls.length) {
      final nextUrls = [...state.optionalDocUrls]..removeAt(index);
      emit(state.copyWith(optionalDocUrls: nextUrls));
    } else {
      final pathIndex = index - state.optionalDocUrls.length;
      final nextPaths = [...state.optionalDocPaths]..removeAt(pathIndex);
      emit(state.copyWith(optionalDocPaths: nextPaths));
    }
  }

  Future<void> submitForm() async {
    if (!state.isFormComplete) {
      emit(
        state.copyWith(
          submitStatus: FormzSubmissionStatus.failure,
          error: 'Vui lòng điền đủ thông tin và tải lên 2 mặt CCCD.',
        ),
      );
      return;
    }

    emit(state.copyWith(submitStatus: FormzSubmissionStatus.inProgress));

    try {
      final uid = _repository.currentUserId;
      if (uid == null) throw Exception('Bạn chưa đăng nhập');

      final List<int> numOfRoomsList = state.requestedQuotasList
          .map((q) => int.tryParse(q.value) ?? 0)
          .toList();

      await LandlordUploadWorker.saveDraftToQueue(
        uid: uid,
        fullName: state.fullName.value,
        phone: state.phone.value,
        address: state.address.value,

        numOfRoomsList: numOfRoomsList,

        cccdFrontPath: state.cccdFrontPath ?? state.cccdFrontUrl ?? '',
        cccdBackPath: state.cccdBackPath ?? state.cccdBackUrl ?? '',
        optionalDocPaths: [...state.optionalDocUrls, ...state.optionalDocPaths],
      );

      LandlordUploadWorker.checkAndUploadDraft();

      emit(state.copyWith(submitStatus: FormzSubmissionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          submitStatus: FormzSubmissionStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }
}
