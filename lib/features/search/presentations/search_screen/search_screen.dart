import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../../../home/data/models/room_filter_draft.dart';
import '../../blocs/room_filter/room_filter_cubit.dart';
import '../../blocs/room_filter/room_filter_state.dart';
import 'widgets/room_filter_form_slivers.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomFilterCubit, RoomFilterState>(
      listenWhen: (prev, curr) {
        final readyForResults =
            prev.isApplying &&
            !curr.isApplying &&
            curr.applyError == null &&
            curr.applyResults != null &&
            curr.applyTarget == FilterApplyTarget.list;
        final hasNewError =
            curr.applyError != null &&
            curr.applyError != prev.applyError &&
            !curr.isApplying;
        return readyForResults || hasNewError;
      },
      listener: (context, state) {
        if (state.applyTarget == FilterApplyTarget.list &&
            !state.isApplying &&
            state.applyError == null &&
            state.applyResults != null) {
          context.push(RouteNames.filterResultsPage);
          return;
        }
        final err = state.applyError;
        if (err != null && err.isNotEmpty) {
          Alerts.of(context).showError(err);
        }
      },
      builder: (context, state) {
        final draft = state.draft;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Lọc tìm phòng'),
            centerTitle: true,
            leading: BackButton(onPressed: () => context.pop()),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                onPressed: draft == RoomFilterDraft.initial
                    ? null
                    : () =>
                          context.read<RoomFilterCubit>().resetDraftToInitial(),
                child: const Text('Đặt lại'),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: const [RoomFilterFormSlivers()],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  0,
                  16.w,
                  16.h + MediaQuery.paddingOf(context).bottom,
                ),
                child: FilledButton(
                  onPressed: state.isApplying
                      ? null
                      : () => context.read<RoomFilterCubit>().applyFilter(
                          target: FilterApplyTarget.list,
                        ),
                  child: state.isApplying
                      ? SizedBox(
                          height: 22.h,
                          width: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Áp dụng'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
