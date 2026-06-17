import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/property_details_live/property_details_live_cubit.dart';
import '../../../data/models/property_model.dart';
import '../../../data/models/room_model.dart';
import 'property_details_screen.dart';


class PropertyDetailsRouteShell extends StatefulWidget {
  const PropertyDetailsRouteShell({
    super.key,
    required this.property,
    required this.rooms,
  });

  final PropertyModel property;
  final List<RoomModel> rooms;

  @override
  State<PropertyDetailsRouteShell> createState() =>
      _PropertyDetailsRouteShellState();
}

class _PropertyDetailsRouteShellState extends State<PropertyDetailsRouteShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<PropertyDetailsLiveCubit>().start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PropertyDetailsScreen(
      property: widget.property,
      rooms: widget.rooms,
    );
  }
}
