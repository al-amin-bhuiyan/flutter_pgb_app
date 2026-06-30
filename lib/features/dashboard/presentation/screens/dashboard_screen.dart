import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/app_icon_button.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../features/geofence/data/services/geofence_manager.dart';
import '../../../../features/geofence/data/services/permission_manager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _initializeGeofencing();
  }

  Future<void> _initializeGeofencing() async {
    final permissionManager = sl<PermissionManager>();
    final hasPermission = await permissionManager.checkLocationPermissions();
    if (!hasPermission) {
      final granted = await permissionManager.requestLocationPermissions();
      if (granted) {
        sl<GeofenceManager>().startMonitoring();
      }
    } else {
      sl<GeofenceManager>().startMonitoring();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.tabletBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              width: AppDimensions.space7XL,
              height: AppDimensions.space7XL,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(Icons.radar, color: AppColors.white, size: AppDimensions.fontTitleS),
            ),
            SizedBox(width: AppDimensions.spaceM + 2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Field',
                    style: AppTextStyles.titleSmall,
                  ),
                  TextSpan(
                    text: 'Track',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          AppIconButton(
            icon: Icons.logout,
            color: AppColors.textSecondary,
            size: AppDimensions.iconL,
            onPressed: () async {
              await sl<AuthRepository>().logout();
              sl<GeofenceManager>().stopMonitoring();
              if (context.mounted) {
                context.go(AppRouter.loginPath);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppDimensions.spaceL),
              Text(
                'Welcome Back!',
                style: AppTextStyles.display,
              ),
              SizedBox(height: AppDimensions.spaceS),
              Text(
                'Track geofences and update checklists on the field.',
                style: AppTextStyles.bodySmall,
              ),
              SizedBox(height: AppDimensions.space6XL),
              
              Expanded(
                child: isTablet
                    ? GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppDimensions.paddingL,
                        mainAxisSpacing: AppDimensions.paddingL,
                        childAspectRatio: 2.2,
                        children: [
                          _buildMenuCard(
                            context: context,
                            title: 'Manage Locations',
                            subtitle: 'Configure boundaries & geofence notifications',
                            icon: Icons.my_location,
                            color: AppColors.primary,
                            onTap: () => context.push(AppRouter.locationsPath),
                          ),
                          _buildMenuCard(
                            context: context,
                            title: 'Tasks Checklist',
                            subtitle: 'View, complete & auto-sync pending checklist items',
                            icon: Icons.checklist_rounded,
                            color: AppColors.textPrimary,
                            onTap: () => context.push(AppRouter.todosPath),
                          ),
                        ],
                      )
                    : ListView(
                        children: [
                          _buildMenuCard(
                            context: context,
                            title: 'Manage Locations',
                            subtitle: 'Configure boundaries & geofence notifications',
                            icon: Icons.my_location,
                            color: AppColors.primary,
                            onTap: () => context.push(AppRouter.locationsPath),
                          ),
                          SizedBox(height: AppDimensions.spaceXXL),
                          _buildMenuCard(
                            context: context,
                            title: 'Tasks Checklist',
                            subtitle: 'View, complete & auto-sync pending checklist items',
                            icon: Icons.checklist_rounded,
                            color: AppColors.textPrimary,
                            onTap: () => context.push(AppRouter.todosPath),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.paddingXXL),
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            side: const BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A19202D),
              blurRadius: 20,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: AppDimensions.sizeAvatar,
              height: AppDimensions.sizeAvatar,
              decoration: ShapeDecoration(
                color: color.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: AppDimensions.iconXL,
              ),
            ),
            SizedBox(width: AppDimensions.spaceXXL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium,
                  ),
                  SizedBox(height: AppDimensions.spaceS),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textLight,
              size: AppDimensions.iconXS,
            ),
          ],
        ),
      ),
    );
  }
}
