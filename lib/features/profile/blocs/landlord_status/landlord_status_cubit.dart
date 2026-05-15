import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/landlord_register_repository.dart';
import 'landlord_status_state.dart';

class LandlordStatusCubit extends Cubit<LandlordStatusState> {
  LandlordStatusCubit({required LandlordRegisterRepository repository})
      : _repository = repository,
        super(LandlordStatusInitial()) {
    _watchStatus(); 
  }

  final LandlordRegisterRepository _repository;
  StreamSubscription? _subscription;

  void _watchStatus() {
    emit(LandlordStatusLoading());
    
    _subscription = _repository.watchCurrentUserRequest().listen(
      (request) {
        if (request == null) {
          emit(LandlordStatusInitial()); 
        } else {
          emit(LandlordStatusLoaded(request));
        }
      },
      onError: (error) {
        emit(LandlordStatusError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel(); 
    return super.close();
  }
}