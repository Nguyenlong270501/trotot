import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/route/app_routes.dart';
import '../../../core/theme/app_style.dart';
import '../../home/data/models/room_model.dart';
import '../blocs/room_filter/room_filter_cubit.dart';
import '../blocs/room_filter/room_filter_state.dart';
import '../../home/presentation/widgets/property_card.dart';

class FilterResultsScreen extends StatelessWidget {
  const FilterResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<RoomFilterCubit>().stopFilterWatch();
        }
      },
      child: BlocBuilder<RoomFilterCubit, RoomFilterState>(
        buildWhen: (prev, curr) =>
            prev.isApplying != curr.isApplying ||
            prev.applyResults != curr.applyResults,
        builder: (context, state) {
          if (state.isApplying && state.applyResults == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Kết quả lọc')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final properties = state.applyResults ?? const [];

          return Scaffold(
            appBar: AppBar(title: const Text('Kết quả lọc')),
            body: properties.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        'Không có phòng phù hợp với bộ lọc. Bỏ bớt chip hoặc đổi khu vực rồi thử lại.',
                        textAlign: TextAlign.center,
                        style: AppTypography.medium14(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                    itemCount: properties.length,
                    separatorBuilder: (_, __) => AppSizes.gapH16,
                    itemBuilder: (context, i) {
                      final property = properties[i];
                      return PropertyCard(
                        property: property,
                        onTap: () {
                          context.push(
                            RouteNames.propertyDetailsPage,
                            extra: {
                              'property': property,
                              'rooms': property.rooms ?? <RoomModel>[],
                            },
                          );
                        },
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
