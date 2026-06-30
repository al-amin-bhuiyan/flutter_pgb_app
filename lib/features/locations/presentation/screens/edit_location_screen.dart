import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_icon_button.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/geofence_location.dart';
import '../bloc/locations_bloc.dart';
import '../bloc/locations_event.dart';
import '../bloc/locations_state.dart';

class EditLocationScreen extends StatelessWidget {
  final GeofenceLocation location;

  const EditLocationScreen({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationsBloc>(
      create: (context) => sl<LocationsBloc>(),
      child: EditLocationForm(location: location),
    );
  }
}

class EditLocationForm extends StatefulWidget {
  final GeofenceLocation location;

  const EditLocationForm({
    super.key,
    required this.location,
  });

  @override
  State<EditLocationForm> createState() => _EditLocationFormState();
}

class _EditLocationFormState extends State<EditLocationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _radiusController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location.name);
    _latController = TextEditingController(text: widget.location.latitude.toString());
    _lngController = TextEditingController(text: widget.location.longitude.toString());
    _radiusController = TextEditingController(text: widget.location.radius.toInt().toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
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
        title: Text(
          'Edit Location',
          style: AppTextStyles.titleMedium,
        ),
        leading: AppIconButton(
          icon: Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: AppDimensions.fontTitleM,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<LocationsBloc, LocationsState>(
        listener: (context, state) {
          if (state is LocationsActionSuccess) {
            Navigator.of(context).pop(true);
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
            final isLoading = state is LocationsLoading;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.paddingXL),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 600.0 : double.infinity,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: EdgeInsets.all(AppDimensions.paddingXXL),
                      decoration: ShapeDecoration(
                        color: AppColors.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusContainer),
                          side: const BorderSide(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x1E19202D),
                            blurRadius: 30,
                            offset: Offset(0, 8),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update geofence boundary coordinates',
                            style: AppTextStyles.bodySmall,
                          ),
                          SizedBox(height: AppDimensions.space3XL),
                          
                          // Name input
                          AppTextField(
                            controller: _nameController,
                            labelText: 'Location Name',
                            hintText: 'e.g. Downtown Office',
                            prefixIcon: Icons.title,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter location name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppDimensions.spaceXXL),

                          // Latitude input
                          AppTextField(
                            controller: _latController,
                            labelText: 'Latitude',
                            hintText: 'e.g. 23.8103',
                            prefixIcon: Icons.explore_outlined,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter latitude';
                              }
                              final lat = double.tryParse(value);
                              if (lat == null) {
                                return 'Please enter a valid number';
                              }
                              if (lat < -90 || lat > 90) {
                                return 'Latitude must be between -90 and 90';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppDimensions.spaceXXL),

                          // Longitude input
                          AppTextField(
                            controller: _lngController,
                            labelText: 'Longitude',
                            hintText: 'e.g. 90.4125',
                            prefixIcon: Icons.explore_outlined,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter longitude';
                              }
                              final lng = double.tryParse(value);
                              if (lng == null) {
                                return 'Please enter a valid number';
                              }
                              if (lng < -180 || lng > 180) {
                                return 'Longitude must be between -180 and 180';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppDimensions.spaceXXL),

                          // Radius input
                          AppTextField(
                            controller: _radiusController,
                            labelText: 'Radius (meters)',
                            hintText: 'e.g. 150',
                            prefixIcon: Icons.circle_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter radius';
                              }
                              final radius = double.tryParse(value);
                              if (radius == null || radius <= 0) {
                                return 'Please enter a positive radius';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppDimensions.space7XL),

                          // Submit Button
                          AppButton(
                            text: 'Update Location',
                            isLoading: isLoading,
                            onPressed: _submitForm,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<LocationsBloc>().add(
            UpdateLocationEvent(
              location: GeofenceLocation(
                id: widget.location.id,
                name: _nameController.text.trim(),
                latitude: double.parse(_latController.text.trim()),
                longitude: double.parse(_lngController.text.trim()),
                radius: double.parse(_radiusController.text.trim()),
              ),
            ),
          );
    }
  }
}
