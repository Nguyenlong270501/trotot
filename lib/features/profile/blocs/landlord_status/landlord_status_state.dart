import 'package:equatable/equatable.dart';
import '../../data/models/landlord_request.dart';

abstract class LandlordStatusState extends Equatable {
  const LandlordStatusState();

  @override
  List<Object?> get props => [];
}

class LandlordStatusInitial extends LandlordStatusState {}

class LandlordStatusLoading extends LandlordStatusState {}

class LandlordStatusLoaded extends LandlordStatusState {
  final LandlordRequest request;

  const LandlordStatusLoaded(this.request);

  @override
  List<Object?> get props => [request];
}

class LandlordStatusError extends LandlordStatusState {
  final String error;

  const LandlordStatusError(this.error);

  @override
  List<Object?> get props => [error];
}