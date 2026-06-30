import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../bloc/locations_bloc.dart';
import '../bloc/locations_event.dart';
import '../bloc/locations_state.dart';

class AddLocationScreen extends StatelessWidget {
  const AddLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationsBloc>(
      create: (context) => sl<LocationsBloc>(),
      child: const AddLocationForm(),
    );
  }
}

class AddLocationForm extends StatefulWidget {
  const AddLocationForm({super.key});

  @override
  State<AddLocationForm> createState() => _AddLocationFormState();
}

class _AddLocationFormState extends State<AddLocationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _radiusController = TextEditingController();

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
    return Scaffold(
      backgroundColor: const Color(0xFFEBEDF1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Add Location',
          style: TextStyle(
            color: Color(0xFF1E2530),
            fontWeight: FontWeight.w700,
            fontSize: 20,
            fontFamily: 'Inter',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E2530), size: 20),
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
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: BlocBuilder<LocationsBloc, LocationsState>(
          builder: (context, state) {
            final isLoading = state is LocationsLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF4F6F8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(
                        color: Color(0xFFE6EAEF),
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
                      const Text(
                        'Set up geofence boundary coordinates',
                        style: TextStyle(
                          color: Color(0xFF5C6675),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 24),
                      
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
                      const SizedBox(height: 18),

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
                      const SizedBox(height: 18),

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
                      const SizedBox(height: 18),

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
                      const SizedBox(height: 32),

                      // Submit Button
                      AppButton(
                        text: 'Save Location',
                        isLoading: isLoading,
                        onPressed: _submitForm,
                      ),
                    ],
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
            AddLocationEvent(
              name: _nameController.text.trim(),
              latitude: double.parse(_latController.text.trim()),
              longitude: double.parse(_lngController.text.trim()),
              radius: double.parse(_radiusController.text.trim()),
            ),
          );
    }
  }
}
