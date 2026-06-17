import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trotot/core/constants/app_sizes.dart';
import 'package:trotot/core/theme/app_colors.dart';
import '../../../../../../core/constants/property_constants.dart';
import '../../../../../../core/theme/app_style.dart';

class SearchBarCard extends StatefulWidget {
  const SearchBarCard({
    super.key,
    this.onTap,
    this.onMapTap,
    this.onCitySelected,
    this.locationName = 'Hà Nội',
    this.cityOptions = PropertyConstants.cities,
  });

  final VoidCallback? onTap;
  final VoidCallback? onMapTap;
  final ValueChanged<String>? onCitySelected;
  final String locationName;
  final List<String> cityOptions;

  @override
  State<SearchBarCard> createState() => _SearchBarCardState();
}

class _SearchBarCardState extends State<SearchBarCard> {
  final LayerLink _cityMenuLink = LayerLink();
  final ValueNotifier<bool> _cityMenuOpen = ValueNotifier(false);

  OverlayEntry? _cityMenuOverlay;

  bool get _canPickCity =>
      widget.onCitySelected != null && widget.cityOptions.isNotEmpty;

  void _toggleCityMenu() {
    if (!_canPickCity) return;

    if (_cityMenuOverlay == null) {
      _showCityMenu();
    } else {
      _hideCityMenu();
    }
  }

  void _showCityMenu() {
    _cityMenuOpen.value = true;

    _cityMenuOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideCityMenu,
              ),
            ),
            CompositedTransformFollower(
              link: _cityMenuLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: Offset(0, 6.h),
              child: Material(
                elevation: 6,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(14.r),
                color: Colors.white,
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < widget.cityOptions.length; i++) ...[
                        if (i > 0)
                          Divider(height: 1, color: Colors.grey.shade200),
                        _CityOptionTile(
                          city: widget.cityOptions[i],
                          isSelected:
                              widget.cityOptions[i] == widget.locationName,
                          onTap: () => _selectCity(widget.cityOptions[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_cityMenuOverlay!);
  }

  void _hideCityMenu() {
    _cityMenuOverlay?.remove();
    _cityMenuOverlay = null;
    _cityMenuOpen.value = false;
  }

  void _selectCity(String city) {
    _hideCityMenu();
    widget.onCitySelected?.call(city);
  }

  @override
  void dispose() {
    _hideCityMenu();
    _cityMenuOpen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          CompositedTransformTarget(
            link: _cityMenuLink,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _canPickCity ? _toggleCityMenu : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: const Color(0xFFE53935),
                    size: 20.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    widget.locationName,
                    style: AppTypography.medium14(color: Colors.black87),
                  ),
                  SizedBox(width: 2.w),
                  ValueListenableBuilder<bool>(
                    valueListenable: _cityMenuOpen,
                    builder: (_, isOpen, __) {
                      return Icon(
                        isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade500,
                        size: 18.sp,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(width: 1.w, height: 20.h, color: Colors.grey.shade300),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: widget.onTap,
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade500,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Tìm trọ theo khu vực, tiện ích...',
                      style: AppTypography.medium14(
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.onMapTap != null) ...[
            AppSizes.gapW12,
            Container(width: 1.w, height: 20.h, color: AppColors.textMuted),
            AppSizes.gapW2,
            InkWell(
              onTap: widget.onMapTap,
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Icon(
                  Icons.map_outlined,
                  color: const Color(0xFF5E5CA8),
                  size: 28.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CityOptionTile extends StatelessWidget {
  const _CityOptionTile({
    required this.city,
    required this.isSelected,
    required this.onTap,
  });

  final String city;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              city,
              style: AppTypography.medium14(
                color: isSelected ? const Color(0xFF5E5CA8) : Colors.black87,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 6.w),
              Icon(
                Icons.check_rounded,
                size: 16.sp,
                color: const Color(0xFF5E5CA8),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
