import 'package:formz/formz.dart';
import '../utils/validators.dart';

enum UsernameValidationError { empty, invalid }

class Username extends FormzInput<String, UsernameValidationError> {
  const Username.pure() : super.pure('');
  const Username.dirty(super.value) : super.dirty();

  @override
  UsernameValidationError? validator(String value) {
    if (value.isEmpty) {
      return UsernameValidationError.empty;
    } else if (!Validators.isValidUsername(value)) {
      return UsernameValidationError.invalid;
    }
    return null;
  }
}
