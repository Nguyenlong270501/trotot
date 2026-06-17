import 'package:formz/formz.dart';

import '../utils/validators.dart';

enum AddressLineValidationError { empty, invalid }

class AddressLine extends FormzInput<String, AddressLineValidationError> {
  const AddressLine.pure() : super.pure('');
  const AddressLine.dirty(super.value) : super.dirty();

  @override
  AddressLineValidationError? validator(String value) {
    if (value.trim().isEmpty) {
      return AddressLineValidationError.empty;
    }
    if (!Validators.isValidAddressLine(value)) {
      return AddressLineValidationError.invalid;
    }
    return null;
  }
}
