import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/theme/app_style.dart';
import '../../../auth/data/models/user.dart';
import '../../../auth/blocs/auth_blocs/auth_cubit.dart';
import '../../../auth/blocs/auth_blocs/auth_state.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, state) {
        UserModel? currentUser;
        if (state is AuthenticationSuccessState) {
          currentUser = state.user;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                AppSizes.gapW12,
                Container(
                  width: AppSizes.iconSizeMedium,
                  height: AppSizes.iconSizeMedium,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FF),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade500, width: 1),
                  ),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
                AppSizes.gapW12,
                Text(
                  'Trọ Tốt',
                  style: AppTypography.bold24(color: const Color(0xFF6062B8)),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: InkWell(
                onTap: currentUser == null
                    ? null
                    : () {
                        context.pushNamed(
                          RouteNames.editProfilePage,
                          extra: currentUser,
                        );
                      },
                child: CircleAvatar(
                  radius: AppSizes.iconSizeMedium / 2,
                  backgroundImage: (currentUser?.avatarUrl?.isNotEmpty ?? false)
                      ? NetworkImage(currentUser!.avatarUrl!)
                      : const AssetImage('assets/images/profile.png'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
