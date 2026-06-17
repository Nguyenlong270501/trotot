import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class PropertyMapSection extends StatefulWidget {
  const PropertyMapSection({
    super.key,
    required this.location,
    required this.fullAddress,
  });

  final LatLng location;
  final String fullAddress;

  @override
  State<PropertyMapSection> createState() => _PropertyMapSectionState();
}

class _PropertyMapSectionState extends State<PropertyMapSection> {
  var _mapReady = false;
  Set<Marker>? _markers;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _mapReady = true;
          _markers = {
            Marker(
              markerId: const MarkerId('propertyLocation'),
              position: widget.location,
              infoWindow: InfoWindow(title: widget.fullAddress),
            ),
          };
        });
      });
    });
  }

  Future<void> _openGoogleMapsApp() async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${widget.location.latitude},${widget.location.longitude}';
    final url = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _openFullScreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FullScreenMapScreen(
          location: widget.location,
          fullAddress: widget.fullAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 250.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _mapReady && _markers != null
                  ? _InlineMap(
                      key: const ValueKey('map'),
                      location: widget.location,
                      markers: _markers!,
                      onOpenFullScreen: () => _openFullScreenMap(context),
                      onOpenExternal: _openGoogleMapsApp,
                    )
                  : _MapPlaceholder(
                      key: const ValueKey('map_placeholder'),
                      fullAddress: widget.fullAddress,
                      onOpenExternal: _openGoogleMapsApp,
                    ),
            ),
          ),
        ),
        AppSizes.gapH12,
        Text(
          widget.fullAddress,
          style: AppTypography.bold14(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({
    super.key,
    required this.fullAddress,
    required this.onOpenExternal,
  });

  final String fullAddress;
  final VoidCallback onOpenExternal;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceMuted,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 48.sp,
                    color: AppColors.textMuted,
                  ),
                  AppSizes.gapH8,
                  Text(
                    fullAddress,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.medium14(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10.h,
            right: 10.w,
            child: ElevatedButton(
              onPressed: onOpenExternal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 4,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 16.sp, color: Colors.blue),
                  SizedBox(width: 5.w),
                  Text(
                    'Mở Google Maps',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMap extends StatelessWidget {
  const _InlineMap({
    super.key,
    required this.location,
    required this.markers,
    required this.onOpenFullScreen,
    required this.onOpenExternal,
  });

  final LatLng location;
  final Set<Marker> markers;
  final VoidCallback onOpenFullScreen;
  final VoidCallback onOpenExternal;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: location,
            zoom: 15,
          ),
          zoomControlsEnabled: false,
          markers: markers,
          mapType: MapType.normal,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
        ),
        Positioned(
          top: 10.h,
          right: 10.w,
          child: GestureDetector(
            onTap: onOpenFullScreen,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.open_in_full,
                size: 16.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10.h,
          right: 10.w,
          child: ElevatedButton(
            onPressed: onOpenExternal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 4,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, size: 16.sp, color: Colors.blue),
                SizedBox(width: 5.w),
                Text(
                  'Mở Google Maps',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FullScreenMapScreen extends StatelessWidget {
  const FullScreenMapScreen({
    super.key,
    required this.location,
    required this.fullAddress,
  });

  final LatLng location;
  final String fullAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          fullAddress,
          style: AppTypography.bold16(color: AppColors.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: location, zoom: 16),
        markers: {
          Marker(
            markerId: const MarkerId('full_screen_property'),
            position: location,
            infoWindow: InfoWindow(title: fullAddress, snippet: fullAddress),
          ),
        },
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        compassEnabled: true,
      ),
    );
  }
}
