import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trotot/core/constants/app_sizes.dart';
import 'package:trotot/features/home/presentation/widgets/property_card/info_row.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';
import '../../../../../../core/utils/property_helper.dart';
import '../../../../../profile/presentation/screens/landlord_register/section_card.dart';
import '../../../../data/models/property_model.dart';
import '../../../../data/models/room_model.dart';

class PropertySpecsPrices extends StatelessWidget {
  final List<RoomModel> room;
  final PropertyModel property;

  const PropertySpecsPrices({
    super.key,
    required this.room,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _SpecItem(
        icon: Icons.bolt_rounded,
        iconBg: AppColors.warningLight,
        iconColor: AppColors.warningDark,
        label: 'Điện',
        value: PropertyHelper.formatFeePerUnit(
          property.electricityPrice.toString(),
          'đ/kWh',
        ),
      ),
      _SpecItem(
        icon: Icons.water_drop_outlined,
        iconBg: AppColors.infoLight,
        iconColor: AppColors.primary,
        label: 'Nước',
        value: PropertyHelper.formatFeePerUnit(
          property.waterPrice.toString(),
          'đ/m³',
        ),
      ),
      _SpecItem(
        icon: Icons.wifi_rounded,
        iconBg: AppColors.successLight,
        iconColor: AppColors.successDark,
        label: 'Internet',
        value: PropertyHelper.formatFeePerUnit(
          property.wifiPrice.toString(),
          'đ/tháng',
        ),
      ),
      _SpecItem(
        icon: Icons.directions_car_outlined,
        iconBg: AppColors.warningLight,
        iconColor: AppColors.warningDark,
        label: 'Gửi xe',
        value: PropertyHelper.formatFeePerUnit(
          property.parkingFee.toString(),
          'đ/tháng',
        ),
      ),
    ];

    return SectionCard(
      title: 'Bảng giá dịch vụ',
      emoji: '💰',
      child: Column(
        children: [
          GridView.count(
            padding: EdgeInsets.zero,
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 3.2,
            children: items.map((item) => _SpecCard(item: item)).toList(),
          ),
          AppSizes.gapH8,
          // service fee
          _SpecCard(
            item: _SpecItem(
              icon: Icons.miscellaneous_services_outlined,
              iconBg: AppColors.successLight,
              iconColor: AppColors.successDark,
              label: 'Phí dịch vụ chung',
              value: PropertyHelper.formatFeePerUnit(
                property.serviceFee.toString(),
                'đ/tháng',
              ),
            ),
          ),
          AppSizes.gapH6,
          if (property.serviceDescription != null &&
              property.serviceDescription!.trim().isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: InfoRow(
                label: 'Mô tả phí dịch vụ chung: ',
                value: property.serviceDescription!,
              ),
            ),
        ],
      ),
    );
  }
}

class _SpecItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  const _SpecItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });
}

class _SpecCard extends StatelessWidget {
  final _SpecItem item;

  const _SpecCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(item.icon, size: 15.sp, color: item.iconColor),
          ),
          AppSizes.gapW8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: AppTypography.medium12(color: AppColors.textMuted),
                  maxLines: 1,
                ),
                AppSizes.gapH1,
                Text(
                  item.value,
                  style: AppTypography.medium12(color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
