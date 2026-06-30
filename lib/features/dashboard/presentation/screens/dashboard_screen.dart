import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/dimensions.dart';
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
      backgroundColor: const Color(0xFFEBEDF1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              width: AppDimensions.space7XL,
              height: AppDimensions.space7XL,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(Icons.radar, color: Colors.white, size: AppDimensions.fontTitleS),
            ),
            SizedBox(width: AppDimensions.spaceM + 2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Field',
                    style: TextStyle(
                      color: const Color(0xFF131A24),
                      fontSize: AppDimensions.fontTitleS,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                  TextSpan(
                    text: 'Track',
                    style: TextStyle(
                      color: const Color(0xFF0D9488),
                      fontSize: AppDimensions.fontTitleS,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: const Color(0xFF5C6675), size: AppDimensions.iconL),
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
                style: TextStyle(
                  color: const Color(0xFF131A24),
                  fontSize: AppDimensions.fontDisplayS,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: AppDimensions.spaceS),
              Text(
                'Track geofences and update checklists on the field.',
                style: TextStyle(
                  color: const Color(0xFF5C6675),
                  fontSize: AppDimensions.fontL,
                  fontFamily: 'Inter',
                ),
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
                            color: const Color(0xFF0D9488),
                            onTap: () => context.push(AppRouter.locationsPath),
                          ),
                          _buildMenuCard(
                            context: context,
                            title: 'Tasks Checklist',
                            subtitle: 'View, complete & auto-sync pending checklist items',
                            icon: Icons.checklist_rounded,
                            color: const Color(0xFF1E2530),
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
                            color: const Color(0xFF0D9488),
                            onTap: () => context.push(AppRouter.locationsPath),
                          ),
                          SizedBox(height: AppDimensions.spaceXXL),
                          _buildMenuCard(
                            context: context,
                            title: 'Tasks Checklist',
                            subtitle: 'View, complete & auto-sync pending checklist items',
                            icon: Icons.checklist_rounded,
                            color: const Color(0xFF1E2530),
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
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            side: const BorderSide(
              color: Color(0xFFE6EAEF),
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
                    style: TextStyle(
                      fontSize: AppDimensions.fontTitleS,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF131A24),
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceS),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppDimensions.fontM,
                      color: const Color(0xFF6B7480),
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF6B7480),
              size: AppDimensions.iconXS,
            ),
          ],
        ),
      ),
    );
  }
}
