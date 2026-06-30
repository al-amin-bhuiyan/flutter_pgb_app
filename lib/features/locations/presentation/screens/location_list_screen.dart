import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/app_icon_button.dart';
import '../../domain/entities/geofence_location.dart';
import '../bloc/locations_bloc.dart';
import '../bloc/locations_event.dart';
import '../bloc/locations_state.dart';

class LocationListScreen extends StatelessWidget {
  const LocationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationsBloc>(
      create: (context) => sl<LocationsBloc>()..add(LoadLocationsEvent()),
      child: const LocationListScreenView(),
    );
  }
}

class LocationListScreenView extends StatefulWidget {
  const LocationListScreenView({super.key});

  @override
  State<LocationListScreenView> createState() => _LocationListScreenViewState();
}

class _LocationListScreenViewState extends State<LocationListScreenView> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.tabletBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        title: Text(
          'Locations',
          style: AppTextStyles.titleMedium,
        ),
        leading: AppIconButton(
          icon: Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: AppDimensions.fontTitleM,
          onPressed: () => context.go(AppRouter.dashboardPath),
        ),
      ),
      body: BlocListener<LocationsBloc, LocationsState>(
        listener: (context, state) {
          if (state is LocationsActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primary,
              ),
            );
            context.read<LocationsBloc>().add(LoadLocationsEvent());
          } else if (state is LocationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<LocationsBloc, LocationsState>(
          builder: (context, state) {
            if (state is LocationsLoading || state is LocationsInitial) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state is LocationsLoaded) {
              final locations = state.locations;

              if (locations.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding3XL + 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: AppDimensions.sizeLogo + 20,
                          height: AppDimensions.sizeLogo + 20,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_off_outlined,
                            size: AppDimensions.iconXXL,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: AppDimensions.space3XL),
                        Text(
                          'No locations monitored yet',
                          style: AppTextStyles.titleSmall,
                        ),
                        SizedBox(height: AppDimensions.spaceM),
                        Text(
                          'Add coordinates and radius to set up geofencing boundaries and alerts.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: AppDimensions.space7XL),
                        ElevatedButton.icon(
                          onPressed: () => context.push(AppRouter.addLocationPath).then((_) {
                            if (context.mounted) {
                              context.read<LocationsBloc>().add(LoadLocationsEvent());
                            }
                          }),
                          icon: const Icon(Icons.add, color: AppColors.white),
                          label: const Text(
                            'Add Location',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingXXL,
                              vertical: AppDimensions.paddingL - 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (isTablet) {
                return GridView.builder(
                  padding: EdgeInsets.all(AppDimensions.paddingL),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppDimensions.paddingL,
                    mainAxisSpacing: AppDimensions.paddingL,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    return _buildLocationCard(context, locations[index]);
                  },
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(AppDimensions.paddingL),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  return _buildLocationCard(context, locations[index]);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: BlocBuilder<LocationsBloc, LocationsState>(
        builder: (context, state) {
          if (state is LocationsLoaded && state.locations.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () => context.push(AppRouter.addLocationPath).then((_) {
                if (context.mounted) {
                  context.read<LocationsBloc>().add(LoadLocationsEvent());
                }
              }),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
              ),
              child: const Icon(Icons.add, color: AppColors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, GeofenceLocation location) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.paddingM + 2),
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
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingL),
        key: ValueKey(location.id),
        child: Row(
          children: [
            Container(
              width: AppDimensions.widthIconBg,
              height: AppDimensions.heightIconBg,
              decoration: ShapeDecoration(
                color: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                ),
              ),
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: AppDimensions.iconL,
              ),
            ),
            SizedBox(width: AppDimensions.spaceXXL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    location.name,
                    style: AppTextStyles.bodyLarge,
                  ),
                  SizedBox(height: AppDimensions.spaceS),
                  Text(
                    'Coordinates: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                  ),
                  SizedBox(height: AppDimensions.spaceS),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingS,
                      vertical: AppDimensions.paddingXS,
                    ),
                    decoration: ShapeDecoration(
                      color: AppColors.tealLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      ),
                    ),
                    child: Text(
                      'Radius: ${location.radius.toInt()}m',
                      style: AppTextStyles.badge,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIconButton(
                  icon: Icons.edit_outlined,
                  color: AppColors.textSecondary,
                  size: AppDimensions.iconL,
                  onPressed: () {
                    context.push(AppRouter.editLocationPath, extra: location).then((_) {
                      if (context.mounted) {
                        context.read<LocationsBloc>().add(LoadLocationsEvent());
                      }
                    });
                  },
                ),
                AppIconButton(
                  icon: Icons.delete_outline,
                  color: AppColors.error,
                  size: AppDimensions.iconL,
                  onPressed: () => _showDeleteConfirmation(context, location),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, GeofenceLocation location) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete Location?',
          style: AppTextStyles.titleSmall,
        ),
        content: Text('Are you sure you want to delete "${location.name}"? This will stop geofencing alerts for this area.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textLight)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LocationsBloc>().add(DeleteLocationEvent(id: location.id));
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
