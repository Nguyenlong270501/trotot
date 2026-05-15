import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../core/constants/app_sizes.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';
import '../../../../../../core/utils/property_helper.dart';
import '../../../../data/models/preview_stat.dart';
import '../../../../data/models/room_model.dart';
import '../../../widgets/property_card/emoji_lable.dart';
import '../../../../../../core/widgets/image_carousel.dart';
import '../../../widgets/property_card/summary_chip.dart';

Future<void> showRoomPreviewSheet(BuildContext context, RoomModel data) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _UserRoomPreviewSheet(data: data),
  );
}

class _UserRoomPreviewSheet extends StatelessWidget {
  const _UserRoomPreviewSheet({required this.data});

  final RoomModel data;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DragHandle(),

            _SheetHeader(
              name: data.roomName,
              priceTitle: 'Giá phòng',
              priceLabel: '${PropertyHelper.formatPrice(data.price)} đ/tháng',
              depositTitle: 'Tiền cọc',
              depositLabel:
                  '${PropertyHelper.formatPrice(data.priceDeposit)} đ',
            ),
            const Divider(height: 1, color: AppColors.divider),

            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  16.h,
                  20.w,
                  20.h + bottomInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 200.h,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ImageCarousel(images: data.imageUrls),
                      ),
                    ),

                    AppSizes.gapH16,
                    EmojiLable(
                      stats: [
                        PreviewStat(
                          emoji: '📐',
                          value: PropertyHelper.formatAreaLabel(
                            data.area.toString(),
                          ),
                          label: "Diện tích",
                        ),
                        PreviewStat(
                          emoji: '👥',
                          value: data.maxTenants.toString(),
                          label: "Số người",
                        ),
                        PreviewStat(
                          emoji: '🏢',
                          value: data.roomLocation,
                          label: "Vị trí",
                        ),
                      ],
                    ),
                    AppSizes.gapH20,

                    const _SectionLabel(emoji: '✨', text: 'Tiện ích nội thất'),
                    AppSizes.gapH12,
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        for (final a in data.amenities)
                          SummaryChip(emoji: a.emoji, label: a.label),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.h, bottom: 6.h),
      width: 36.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.name,
    required this.priceTitle,
    required this.priceLabel,
    required this.depositTitle,
    required this.depositLabel,
  });

  final String name;
  final String priceTitle;
  final String priceLabel;
  final String depositTitle;
  final String depositLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.bold18(color: AppColors.textPrimary),
                ),
                AppSizes.gapH4,
                Row(
                  children: [
                    Text(priceTitle, style: AppTypography.bold14()),
                    SizedBox(width: 6.w),
                    Text(
                      priceLabel,
                      style: AppTypography.bold14(color: AppColors.primary),
                    ),
                  ],
                ),
                AppSizes.gapH4,
                Row(
                  children: [
                    Text(depositTitle, style: AppTypography.bold14()),
                    SizedBox(width: 6.w),
                    Text(
                      depositLabel,
                      style: AppTypography.bold14(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: 14.sp)),
        SizedBox(width: 6.w),
        Text(text, style: AppTypography.bold14(color: AppColors.textPrimary)),
      ],
    );
  }
}
