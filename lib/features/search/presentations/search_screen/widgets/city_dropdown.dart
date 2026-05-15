import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/property_constants.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../blocs/room_filter/room_filter_cubit.dart';
import '../../../../home/data/models/room_filter_draft.dart';
import 'outlined_dropdown.dart';

class CityDropdown extends StatelessWidget {
  const CityDropdown({super.key, required this.city});

  final String? city;

  @override
  Widget build(BuildContext context) {
    final selectedCity = city ?? RoomFilterDraft.defaultCity;

    return OutlinedDropdown(
      value: selectedCity,
      items: PropertyConstants.cities
          .map(
            (c) => DropdownMenuItem(
              value: c,
              child: Text(c, style: AppTypography.medium14()),
            ),
          )
          .toList(),
      onChanged: (next) {
        if (next == null) {
          return;
        }
        context.read<RoomFilterCubit>().setCity(next, resetWard: true);
      },
    );
  }
}
