import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../../core/utils/property_helper.dart';
import '../../../../data/models/room_model.dart';
import '../../../widgets/room_mini_card.dart';

/// Collapsible room list on property details (collapsed by default).
class PropertyAvailableRoomsSection extends StatelessWidget {
  const PropertyAvailableRoomsSection({
    super.key,
    required this.rooms,
    required this.onRoomTap,
  });

  final List<RoomModel> rooms;
  final void Function(RoomModel room) onRoomTap;

  static const int _scrollableThreshold = 4;
  static const double _expandedMaxHeight = 280;

  @override
  Widget build(BuildContext context) {
    final count = rooms.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          expandedAlignment: Alignment.centerLeft,
          childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          leading: Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text('🚪', style: TextStyle(fontSize: 14.sp)),
          ),
          title: Text(
            'Danh sách phòng trống ($count phòng)',
            style: AppTypography.bold16(color: AppColors.textPrimary),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              'Chạm để xem danh sách',
              style: AppTypography.medium12(color: AppColors.textMuted),
            ),
          ),
          children: [_buildRoomList()],
        ),
      ),
    );
  }

  Widget _buildRoomList() {
    if (rooms.length <= _scrollableThreshold) {
      return Column(
        children: [
          for (var i = 0; i < rooms.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _roomCard(rooms[i]),
          ],
        ],
      );
    }

    return SizedBox(
      height: _expandedMaxHeight.h,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: rooms.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, index) => _roomCard(rooms[index]),
      ),
    );
  }

  Widget _roomCard(RoomModel room) {
    return RoomMiniCard(
      name: room.roomName,
      priceLabel: '${PropertyHelper.formatPrice(room.price)} đ/tháng',
      onTap: () => onRoomTap(room),
    );
  }
}
