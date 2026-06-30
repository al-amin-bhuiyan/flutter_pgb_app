import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFEBEDF1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.radar, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Field',
                    style: TextStyle(
                      color: Color(0xFF131A24),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                  TextSpan(
                    text: 'Track',
                    style: TextStyle(
                      color: Color(0xFF0D9488),
                      fontSize: 18,
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
            icon: const Icon(Icons.logout, color: Color(0xFF5C6675)),
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  color: Color(0xFF131A24),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Track geofences and update checklists on the field.',
                style: TextStyle(
                  color: Color(0xFF5C6675),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 30),
              
              // Locations Management Card
              _buildMenuCard(
                context: context,
                title: 'Manage Locations',
                subtitle: 'Configure boundaries & geofence notifications',
                icon: Icons.my_location,
                color: const Color(0xFF0D9488),
                onTap: () => context.push(AppRouter.locationsPath),
              ),
              const SizedBox(height: 18),

              // Todos checklist Card
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
              width: 56,
              height: 56,
              decoration: ShapeDecoration(
                color: color.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF131A24),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7480),
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF6B7480),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
