import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/data/models/property_model.dart';
import '../../../search/blocs/room_filter/room_filter_cubit.dart';
import '../../../search/blocs/room_filter/room_filter_state.dart';
import '../blocs/map_search/map_search_cubit.dart';
import '../blocs/map_search/map_search_state.dart';

class MapSearchListeners extends StatelessWidget {
  const MapSearchListeners({
    super.key,
    required this.onFilterRealtimeUpdate,
    required this.onLocationResolved,
    required this.onPropertiesChanged,
    required this.onSelectionChanged,
    required this.child,
  });

  final ValueChanged<List<PropertyModel>> onFilterRealtimeUpdate;
  final ValueChanged<MapSearchState> onLocationResolved;
  final Future<void> Function(MapSearchState state) onPropertiesChanged;
  final Future<void> Function(MapSearchState state) onSelectionChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RoomFilterCubit, RoomFilterState>(
          listenWhen: (previous, current) {
            if (current.applyTarget != FilterApplyTarget.map ||
                !current.isWatchingFilterResults) {
              return false;
            }
            return current.applyResults != null &&
                current.applyResults != previous.applyResults &&
                !current.isApplying;
          },
          listener: (context, state) {
            final results = state.applyResults;
            if (results == null) {
              return;
            }
            onFilterRealtimeUpdate(results);
            context.read<RoomFilterCubit>().clearApplyOutcome(keepTarget: true);
          },
        ),
        BlocListener<MapSearchCubit, MapSearchState>(
          listenWhen: (previous, current) =>
              previous.isResolvingLocation != current.isResolvingLocation ||
              previous.latitude != current.latitude ||
              previous.longitude != current.longitude,
          listener: (context, state) {
            if (!state.isResolvingLocation) {
              onLocationResolved(state);
            }
          },
        ),
        BlocListener<MapSearchCubit, MapSearchState>(
          listenWhen: (previous, current) =>
              previous.properties != current.properties,
          listener: (context, state) async {
            await onPropertiesChanged(state);
          },
        ),
        BlocListener<MapSearchCubit, MapSearchState>(
          listenWhen: (previous, current) =>
              previous.selectedPropertyId != current.selectedPropertyId,
          listener: (context, state) {
            unawaited(onSelectionChanged(state));
          },
        ),
      ],
      child: child,
    );
  }
}
