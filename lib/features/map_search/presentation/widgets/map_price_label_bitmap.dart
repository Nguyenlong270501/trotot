import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Renders a price pill as PNG bytes for MapLibre [addImage].
abstract final class MapPriceLabelBitmap {
  static final Map<String, Uint8List> _cache = {};

  static String imageIdFor(String label, {required bool selected}) {
    final suffix = selected ? 'sel' : 'def';
    return 'map-price-${label.hashCode.abs()}-$suffix';
  }

  static String _cacheKey(String label, bool selected) =>
      '${label.hashCode.abs()}-$selected';

  static Future<Uint8List> build(String label, {bool selected = false}) async {
    final cacheKey = _cacheKey(label, selected);
    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final horizontalPadding = 25.w;
    final verticalPadding = 18.h;
    final pointerHeight = 15.h;
    final pointerWidth = 20.w;
    final borderRadius = 20.r;
    final fontSize = 30.sp;
    const devicePixelRatio = 3.0;

    // Selected: dark pill (card sits directly below — visual link like Airbnb-style maps).
    final backgroundColor = selected ? AppColors.textPrimary : Colors.white;
    final textColor = selected ? Colors.white : AppColors.textPrimary;

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final logicalWidth = textPainter.width + horizontalPadding * 2;
    final logicalHeight =
        textPainter.height + verticalPadding * 2 + pointerHeight;

    final width = (logicalWidth * devicePixelRatio).ceil();
    final height = (logicalHeight * devicePixelRatio).ceil();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.scale(devicePixelRatio);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, logicalWidth, logicalHeight - pointerHeight),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(bodyRect.shift(const Offset(0, 1.5)), shadowPaint);

    final bodyPaint = Paint()..color = backgroundColor;
    canvas.drawRRect(bodyRect, bodyPaint);

    final pointerPath = Path()
      ..moveTo(
        logicalWidth / 2 - pointerWidth / 2,
        logicalHeight - pointerHeight,
      )
      ..lineTo(logicalWidth / 2, logicalHeight)
      ..lineTo(
        logicalWidth / 2 + pointerWidth / 2,
        logicalHeight - pointerHeight,
      )
      ..close();
    canvas.drawPath(pointerPath, bodyPaint);

    textPainter.paint(canvas, Offset(horizontalPadding, verticalPadding));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    _cache[cacheKey] = bytes;
    return bytes;
  }

  static void clearCache() {
    _cache.clear();
  }
}
