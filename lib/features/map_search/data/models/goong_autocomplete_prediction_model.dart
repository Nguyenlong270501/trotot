import 'package:equatable/equatable.dart';

class GoongAutocompletePredictionModel extends Equatable {
  const GoongAutocompletePredictionModel({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  factory GoongAutocompletePredictionModel.fromMap(Map<String, dynamic> map) {
    final formatting = map['structured_formatting'];
    final formattingMap = formatting is Map
        ? Map<String, dynamic>.from(formatting)
        : const <String, dynamic>{};
    final description = map['description']?.toString().trim() ?? '';
    final mainText = formattingMap['main_text']?.toString().trim() ?? '';
    final secondaryText =
        formattingMap['secondary_text']?.toString().trim() ?? '';

    return GoongAutocompletePredictionModel(
      placeId: map['place_id']?.toString().trim() ?? '',
      description: description,
      mainText: mainText.isNotEmpty ? mainText : description,
      secondaryText: secondaryText,
    );
  }

  bool get isValid => placeId.isNotEmpty && description.isNotEmpty;

  @override
  List<Object?> get props => [placeId, description, mainText, secondaryText];
}
