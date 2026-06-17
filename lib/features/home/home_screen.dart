import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/mixins/notification_permission_lifecycle_mixin.dart';
import '../../core/widgets/aurora_background.dart';
import '../favorites/presentation/screens/favorites_tab.dart';
import '../messages/presentation/screens/messages_screen.dart';
import 'blocs/home_suggested_rooms/home_suggested_rooms_cubit.dart';
import 'data/repositories/home_repository.dart';
import '../profile/presentation/screens/profile_screen.dart';
import 'presentation/screens/home/widgets/bottom_bar.dart';
import 'presentation/screens/home/home_main_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialBottomNavIndex = 0,
    this.initialMessagesTabIndex = 0,
  });

  final int initialBottomNavIndex;
  final int initialMessagesTabIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with NotificationPermissionLifecycleMixin<HomeScreen> {
  late final ValueNotifier<int> _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = ValueNotifier<int>(
      widget.initialBottomNavIndex.clamp(0, 3),
    );
  }

  @override
  void dispose() {
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeSuggestedRoomsCubit(repository: context.read<HomeRepository>())
            ..watch(),
      child: Scaffold(
        body: Stack(
          children: [
            const AuroraBackground(darkMode: false, blurSigma: 0),
            SafeArea(
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedIndex,
                builder: (context, currentIndex, child) {
                  return Column(
                    children: [
                      Expanded(
                        child: IndexedStack(
                          index: currentIndex,
                          children: [
                            const HomeMainTab(),
                            const FavoritesTab(),
                            MessagesScreen(
                              initialTabIndex: widget.initialMessagesTabIndex,
                            ),
                            const ProfileScreen(),
                          ],
                        ),
                      ),
                      AppSizes.gapH8,
                      BottomBar(
                        currentIndex: currentIndex,
                        onTabChange: (index) {
                          _selectedIndex.value = index;
                        },
                      ),
                      AppSizes.gapH8,
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
