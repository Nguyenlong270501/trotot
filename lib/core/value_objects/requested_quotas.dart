import 'package:formz/formz.dart';

enum RequestedQuotasValidationError { empty, invalidFormat, tooLarge }

class RequestedQuotas
    extends FormzInput<String, RequestedQuotasValidationError> {
  const RequestedQuotas.pure() : super.pure('');
  const RequestedQuotas.dirty([super.value = '']) : super.dirty();

  @override
  RequestedQuotasValidationError? validator(String value) {
    if (value.isEmpty) return RequestedQuotasValidationError.empty;

    final number = int.tryParse(value);

    if (number == null || number <= 0) {
      return RequestedQuotasValidationError.invalidFormat;
    }

    if (number > 200) {
      return RequestedQuotasValidationError.tooLarge;
    }

    return null;
  }
}
