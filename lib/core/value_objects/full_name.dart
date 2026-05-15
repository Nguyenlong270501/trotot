import 'package:formz/formz.dart';

import '../utils/validators.dart';

enum FullNameValidationError { empty, invalid }

class FullName extends FormzInput<String, FullNameValidationError> {
  const FullName.pure() : super.pure('');
  const FullName.dirty(super.value) : super.dirty();

  @override
  FullNameValidationError? validator(String value) {
    if (value.trim().isEmpty) {
      return FullNameValidationError.empty;
    }
    if (!Validators.isValidFullName(value)) {
      return FullNameValidationError.invalid;
    }
    return null;
  }
}
