import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/property_constants.dart';
import '../../../../core/theme/app_style.dart';

class SearchBarCard extends StatefulWidget {
  const SearchBarCard({
    super.key,
    this.onTap,
    this.onCitySelected,
    this.locationName = 'Hà Nội',
    this.cityOptions = PropertyConstants.cities,
  });

  final void Function()? onTap;
  final ValueChanged<String>? onCitySelected;
  final String locationName;
  final List<String> cityOptions;

  @override
  State<SearchBarCard> createState() => _SearchBarCardState();
}

class _SearchBarCardState extends State<SearchBarCard> {
  bool _cityMenuOpen = false;

  void _toggleCityMenu() {
    if (widget.onCitySelected == null || widget.cityOptions.isEmpty) {
      return;
    }
    setState(() => _cityMenuOpen = !_cityMenuOpen);
  }

  void _selectCity(String city) {
    setState(() => _cityMenuOpen = false);
    widget.onCitySelected?.call(city);
  }

  @override
  Widget build(BuildContext context) {
    final canPickCity =
        widget.onCitySelected != null && widget.cityOptions.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: canPickCity ? _toggleCityMenu : null,
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
                    Icon(
                      _cityMenuOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade500,
                      size: 18.sp,
                    ),
                  ],
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
                          'Tìm trọ theo khu vực, đường phố...',
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
            ],
          ),
        ),
        if (_cityMenuOpen) ...[
          SizedBox(height: 6.h),
          Material(
            elevation: 4,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(12.r),
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
        ],
      ],
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
