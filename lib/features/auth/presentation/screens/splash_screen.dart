import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>()..add(AppStartedEvent()),
      child: const SplashScreenView(),
    );
  }
}

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(AppRouter.dashboardPath);
          } else if (state is Unauthenticated) {
            context.go(AppRouter.loginPath);
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: AppDimensions.sizeLogo,
                height: AppDimensions.sizeLogo,
                decoration: ShapeDecoration(
                  color: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLogo),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x1A0D9488),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: Icon(
                  Icons.radar,
                  color: AppColors.white,
                  size: AppDimensions.space3XL + 6,
                ),
              ),
              SizedBox(height: AppDimensions.space3XL),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Field',
                      style: AppTextStyles.display.copyWith(
                        fontSize: AppDimensions.fontDisplayM,
                      ),
                    ),
                    TextSpan(
                      text: 'Track',
                      style: AppTextStyles.display.copyWith(
                        fontSize: AppDimensions.fontDisplayM,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceM),
              Text(
                'Geofence & Field checklist helper',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
