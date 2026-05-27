import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../../core/utils/property_helper.dart';
import '../../../../data/models/landlord_summary_model.dart';

class LandlordInfoCard extends StatelessWidget {
  const LandlordInfoCard({super.key, required this.landlordSummary});

  final LandlordSummaryModel? landlordSummary;

  static String _nameInitial(String name) {
    final t = name.trim();
    if (t.isEmpty) return '?';
    return t.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final summary = landlordSummary;
    if (summary == null) {
      return Text(
        'Chưa có thông tin chủ nhà',
        style: AppTypography.medium12(color: AppColors.textMuted),
      );
    }

    final displayName = summary.userName.trim().isEmpty
        ? 'Chủ nhà'
        : summary.userName;
    final avatarUrl = summary.avatarUrl?.trim() ?? '';
    final phoneNumber = summary.phoneNumber?.trim() ?? '';
    final tenure = PropertyHelper.landlordHostingTenureLabel(summary.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Row(
              children: [
                _Avatar(
                  imageUrl: avatarUrl,
                  initial: _nameInitial(displayName),
                ),
                AppSizes.gapW16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTypography.bold16(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (phoneNumber.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              size: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                            AppSizes.gapW4,
                            Text(
                              phoneNumber,
                              style: AppTypography.medium14(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (summary.isLandlord == true) ...[
                        AppSizes.gapH2,
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 14.sp,
                              color: AppColors.successDark,
                            ),
                            AppSizes.gapW4,
                            Text(
                              'Đã xác minh',
                              style: AppTypography.medium12(
                                color: AppColors.successDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            AppSizes.gapH24,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(tenure, 'Chủ nhà'),
                _buildDivider(),
                _buildStatItem('—', 'Đánh giá'),
                _buildDivider(),
                _buildStatItem('—', 'Xếp hạng'),
              ],
            ),
            AppSizes.gapH24,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Liên hệ chủ nhà',
                    style: AppTypography.medium14(color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_rounded,
                      size: 20.sp,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSizes.gapH16,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20.sp,
                color: AppColors.textMuted,
              ),
            ),
            AppSizes.gapW12,
            Expanded(
              child: Text(
                'Liên hệ nếu bạn có thắc mắc hoặc cần đặt lịch hẹn để xem phòng trực tiếp.',
                style: AppTypography.medium12(
                  color: AppColors.textMuted,
                ).copyWith(height: 1.4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTypography.bold14(color: AppColors.textPrimary)),
        AppSizes.gapH4,
        Text(label, style: AppTypography.medium12(color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30.h,
      width: 1.w,
      color: AppColors.border.withValues(alpha: 0.9),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl, required this.initial});

  final String imageUrl;
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B1B9A).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: 56.w,
              height: 56.w,
              errorWidget: (_, __, ___) => _initialPlaceholder(),
            )
          : _initialPlaceholder(),
    );
  }

  Widget _initialPlaceholder() {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('assets/images/profile.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
