import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/widgets/image_carousel.dart';
import '../../../../blocs/property_details_live/property_details_live_cubit.dart';
import '../../../../blocs/property_details_live/property_details_live_state.dart';

class PropertyHeaderCarousel extends StatelessWidget {
  const PropertyHeaderCarousel({super.key});

  static double get extent => 280.h;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyDetailsLiveCubit, PropertyDetailsLiveState>(
      buildWhen: (previous, current) =>
          previous.rooms != current.rooms ||
          previous.activeRoomId != current.activeRoomId,
      builder: (context, state) {
        final activeRoom = state.activeRoom;
        final headerImages =
            activeRoom?.imageUrls ??
            (state.rooms.isNotEmpty
                ? state.rooms.first.imageUrls
                : const <String>[]);
        return SizedBox(
          height: extent,
          width: double.infinity,
          child: ImageCarousel(images: headerImages),
        );
      },
    );
  }
}
