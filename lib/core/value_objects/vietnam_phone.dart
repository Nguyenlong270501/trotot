import 'package:formz/formz.dart';

import '../utils/validators.dart';

enum VietnamPhoneValidationError { empty, invalid }

class VietnamPhone extends FormzInput<String, VietnamPhoneValidationError> {
  const VietnamPhone.pure() : super.pure('');
  const VietnamPhone.dirty(super.value) : super.dirty();

  @override
  VietnamPhoneValidationError? validator(String value) {
    if (value.trim().isEmpty) {
      return VietnamPhoneValidationError.empty;
    }
    if (!Validators.isValidVietnamPhone(value)) {
      return VietnamPhoneValidationError.invalid;
    }
    return null;
  }
}
