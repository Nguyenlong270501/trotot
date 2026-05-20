import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'loading_status_chip.dart.dart';

class MapLoadingOverlay extends StatelessWidget {
  const MapLoadingOverlay({
    super.key,
    required this.isResolvingLocation,
    required this.isLoadingProperties,
  });

  final bool isResolvingLocation;
  final bool isLoadingProperties;

  @override
  Widget build(BuildContext context) {
    final label = isResolvingLocation
        ? 'Đang lấy vị trí...'
        : isLoadingProperties
        ? 'Đang tải phòng...'
        : null;

    if (label == null) return const SizedBox.shrink();

    return Positioned(
      top: 12.h,
      left: 0,
      right: 0,
      child: Center(child: LoadingStatusChip(label: label)),
    );
  }
}
