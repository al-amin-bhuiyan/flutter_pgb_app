import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/dimensions.dart';
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
      backgroundColor: const Color(0xFFEBEDF1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Locations',
          style: TextStyle(
            color: const Color(0xFF1E2530),
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.fontTitleM,
            fontFamily: 'Inter',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: const Color(0xFF1E2530), size: AppDimensions.fontTitleM),
          onPressed: () => context.go(AppRouter.dashboardPath),
        ),
      ),
      body: BlocListener<LocationsBloc, LocationsState>(
        listener: (context, state) {
          if (state is LocationsActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF0D9488),
              ),
            );
            context.read<LocationsBloc>().add(LoadLocationsEvent());
          } else if (state is LocationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: BlocBuilder<LocationsBloc, LocationsState>(
          builder: (context, state) {
            if (state is LocationsLoading || state is LocationsInitial) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
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
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_off_outlined,
                            size: AppDimensions.iconXXL,
                            color: const Color(0xFF0D9488),
                          ),
                        ),
                        SizedBox(height: AppDimensions.space3XL),
                        Text(
                          'No locations monitored yet',
                          style: TextStyle(
                            fontSize: AppDimensions.fontTitleS,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E2530),
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceM),
                        Text(
                          'Add coordinates and radius to set up geofencing boundaries and alerts.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppDimensions.fontL,
                            color: const Color(0xFF6B7480),
                            fontFamily: 'Inter',
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
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Add Location',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
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
              backgroundColor: const Color(0xFF0D9488),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
              ),
              child: const Icon(Icons.add, color: Colors.white),
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
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingL),
        key: ValueKey(location.id),
        child: Row(
          children: [
            Container(
              width: AppDimensions.widthIconBg,
              height: AppDimensions.heightIconBg,
              decoration: ShapeDecoration(
                color: const Color(0xFFF4F6F8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                ),
              ),
              child: Icon(
                Icons.location_on,
                color: const Color(0xFF0D9488),
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
                    style: TextStyle(
                      fontSize: AppDimensions.fontXXL,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF131A24),
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceS),
                  Text(
                    'Coordinates: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: AppDimensions.fontM,
                      color: const Color(0xFF6B7480),
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceS),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingS,
                      vertical: AppDimensions.paddingXS,
                    ),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD6F3EF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      ),
                    ),
                    child: Text(
                      'Radius: ${location.radius.toInt()}m',
                      style: TextStyle(
                        fontSize: AppDimensions.fontXS,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0D9488),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: const Color(0xFF5C6675), size: AppDimensions.iconL),
                  onPressed: () {
                    context.push(AppRouter.editLocationPath, extra: location).then((_) {
                      if (context.mounted) {
                        context.read<LocationsBloc>().add(LoadLocationsEvent());
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: AppDimensions.iconL),
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
          style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter', fontSize: AppDimensions.fontTitleS),
        ),
        content: Text('Are you sure you want to delete "${location.name}"? This will stop geofencing alerts for this area.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7480))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LocationsBloc>().add(DeleteLocationEvent(id: location.id));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
