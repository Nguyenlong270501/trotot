import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/constants/property_constants.dart';
import '../../../../../../core/constants/rules_key.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../data/models/amenity_option.dart';
import '../../../../data/models/property_model.dart';
import '../../../widgets/summary_chip.dart';

class PropertyAmenitiesSection extends StatelessWidget {
  final List<String>? facilities;

  const PropertyAmenitiesSection({super.key, required this.facilities});

  @override
  Widget build(BuildContext context) {
    final items = facilities ?? [];

    if (items.isEmpty) {
      return Text(
        'Chưa cập nhật tiện ích.',
        style: AppTypography.medium12(color: AppColors.textMuted),
      );
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: items.map((facilityLabel) {
        final matchedOption = PropertyConstants.amenities.firstWhere(
          (option) => option.label == facilityLabel,
          orElse: () => AmenityOption(emoji: '✅', label: facilityLabel),
        );

        return SummaryChip(
          emoji: matchedOption.emoji,
          label: matchedOption.label,
        );
      }).toList(),
    );
  }
}

class PropertyRulesSection extends StatelessWidget {
  final PropertyModel property;

  const PropertyRulesSection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final rules = property.rules ?? [];
    final chips = <Map<String, String>>[];

    // --- CHUNG CHỦ ---
    if (rules.contains(RuleKeys.noShared)) {
      chips.add({'emoji': '🗝️', 'label': 'Không chung chủ'});
    } else {
      chips.add({'emoji': '🏠', 'label': 'Chung chủ'});
    }

    // --- THÚ CƯNG ---
    if (rules.contains(RuleKeys.allowPet)) {
      chips.add({'emoji': '🐾', 'label': 'Cho nuôi Pet'});
    } else {
      chips.add({'emoji': '🚫', 'label': 'Không nuôi Pet'});
    }

    // --- XE ĐIỆN ---
    if (rules.contains(RuleKeys.electricBike)) {
      chips.add({'emoji': '🛵', 'label': 'Cho sạc xe điện'});
    } else {
      chips.add({'emoji': '❌', 'label': 'Không sạc xe điện'});
    }

    // --- GIỜ GIẤC ---
    if (rules.contains(RuleKeys.freeTime)) {
      chips.add({'emoji': '🕛', 'label': 'Giờ giấc tự do'});
    } else {
      chips.add({
        'emoji': '🔒',
        'label': 'Đóng cửa lúc ${property.curfewTime}',
      });
    }

    // Xử lý ghi chú nội quy
    final hasNotes =
        property.rulesDescription != null &&
        property.rulesDescription!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: chips
              .map((c) => SummaryChip(emoji: c['emoji']!, label: c['label']!))
              .toList(),
        ),

        if (hasNotes) ...[
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.textMuted.withValues(alpha: 0.25),
              ),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Ghi chú nội quy: ',
                    style: AppTypography.bold12(color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: property.rulesDescription!.trim(),
                    style: AppTypography.medium12(
                      color: AppColors.textMuted,
                    ).copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
