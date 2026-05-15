import 'package:flutter/material.dart';

/// Màu dùng chung — đồng bộ với màn hồ sơ / auth (gradient tím–be).
abstract class AppColors {
  AppColors._();

  static const Color scaffoldBackground = Color(0xFFF7F6FA);
  static const Color appBarBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1F1F2E);
  static const Color textSecondary = Color(0xFF51516D);
  static const Color textMuted = Color(0xFF8C8CAA);

  /// Accent chính (tiêu đề app bar, nhấn mạnh)
  static const Color accent = Color(0xFF6062B8);
  static const Color accentDeep = Color(0xFF4A4A8B);
  static const Color accentIcon = Color(0xFF5E5CA8);

  /// Nền ô / chip
  static const Color surfaceMuted = Color(0xFFF1F1F5);
  static const Color surfaceCard = Colors.white;

  /// Thẻ kính mờ (pill app bar, khối avatar trên tab Profile)
  static final Color surfaceSheet = Colors.white.withValues(alpha: 0.9);

  /// Dấu (*) trường bắt buộc
  static const Color requiredMark = Color(0xFFE53935);

  static const List<Color> profileBodyGradient = [
    Color(0xFFE8E6FB),
    Color(0xFFF6EADF),
    Color(0xFFEDEAFB),
  ];

  static const Color badgeMandatoryBg = Color(0xFFE8E6FB);
  static const Color badgeMandatoryText = Color(0xFF4A4A8B);

  /// Nút đăng xuất / cảnh báo
  static const Color dangerSurface = Color(0xFFFBEDED);

  /// Nút camera avatar (edit profile)
  static const Color avatarEditButton = Color(0xFFA3A0E7);

  //
  static const Color primary = Color(0xFF10B981);
  static const Color warningStrongText = Color(0xFF92400E);
  static const Color mutedSoft = Color(0xFF6B7280);

  static const Color textDisabled = Color(0xFF9CA3AF);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color shadowSoft = Color(0x14000000);

  static const Color successSoft = Color(0xFFE8F7EF);
  static const Color warningSoft = Color(0xFFFFF4E0);
  static const Color infoSoft = Color(0xFFEAF2FF);
  static const Color errorSoft = Color(0xFFFDECEC);
  static const Color orangePrimary = Color(0xFFE68500);
  static const Color orangeSoft = Color(0xFFFFF4E0);


 
  // ─── Background ──────────────────────────────────────────────────────────
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF5F5F5);
  static const Color backgroundTertiary = Color(0xFFEFEFEF);
  static const Color imagePlaceholder = Color(0xFFE0E8F4);
 
 
  // ─── Border ───────────────────────────────────────────────────────────────
  static const Color borderTertiary = Color(0xFFE8E8E8);
  static const Color borderSecondary = Color(0xFFD0D0D0);
  static const Color borderPrimary = Color(0xFFB0B0B0);
 
  // ─── Info (xanh dương) ────────────────────────────────────────────────────
  /// Dùng cho: avatar chủ nhà, badge "Mới đăng", spec icon diện tích/nước
  static const Color infoLight = Color(0xFFE6F1FB);
  static const Color infoBorder = Color(0xFFB5D4F4);
  static const Color info = Color(0xFF378ADD);
  static const Color infoDark = Color(0xFF0C447C);
 
  // ─── Success (xanh lá) ────────────────────────────────────────────────────
  /// Dùng cho: badge "Còn phòng", tiện ích có sẵn, nút Đánh giá, spec icon wifi
  static const Color successLight = Color(0xFFEAF3DE);
  static const Color successBorder = Color(0xFFC0DD97);
  static const Color success = Color(0xFF639922);
  static const Color successDark = Color(0xFF27500A);
 
  // ─── Warning (cam/vàng) ───────────────────────────────────────────────────
  /// Dùng cho: spec icon điện, gửi xe
  static const Color warningLight = Color(0xFFFAEEDA);
  static const Color warningBorder = Color(0xFFFAC775);
  static const Color warning = Color(0xFFBA7517);
  static const Color warningDark = Color(0xFF854F0B);
 
  // ─── Danger (đỏ) ──────────────────────────────────────────────────────────
  /// Dùng cho: spec icon đặt cọc, badge hết hạn, nút xóa
  static const Color dangerLight = Color(0xFFFCEBEB);
  static const Color dangerBorder = Color(0xFFF7C1C1);
  static const Color danger = Color(0xFFE24B4A);
  static const Color dangerDark = Color(0xFFA32D2D);
 
  // ─── Star ─────────────────────────────────────────────────────────────────
  /// Màu sao đánh giá
  static const Color starColor = Color(0xFFEF9F27);
 
  // ─── Misc ─────────────────────────────────────────────────────────────────
  static const Color shimmer = Color(0xFFE8E8E8);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color overlay = Color(0x66000000);
}
