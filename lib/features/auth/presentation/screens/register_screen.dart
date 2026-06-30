import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>(),
      child: const RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.tabletBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(AppRouter.dashboardPath);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXL,
                    vertical: AppDimensions.paddingS,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 480.0 : double.infinity,
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Logo
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: AppDimensions.sizeLogo,
                                    height: AppDimensions.sizeLogo,
                                    decoration: ShapeDecoration(
                                      color: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusLogo),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.radar,
                                      color: AppColors.white,
                                      size: AppDimensions.space3XL + 6,
                                    ),
                                  ),
                                  SizedBox(height: AppDimensions.spaceXL),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Field',
                                          style: AppTextStyles.titleLarge,
                                        ),
                                        TextSpan(
                                          text: 'Track',
                                          style: AppTextStyles.titleLarge.copyWith(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: AppDimensions.space4XL),
                            Center(
                              child: Text(
                                'Create Account',
                                style: AppTextStyles.display,
                              ),
                            ),
                            SizedBox(height: AppDimensions.spaceS),
                            Center(
                              child: Text(
                                'Sign up to track coordinates and check lists',
                                style: AppTextStyles.bodySmall,
                              ),
                            ),
                            SizedBox(height: AppDimensions.space3XL),

                            // Full Name Field
                            AppTextField(
                              controller: _nameController,
                              labelText: 'Full Name',
                              hintText: 'John Doe',
                              prefixIcon: Icons.person_outline,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: AppDimensions.spaceXXL),

                            // Email Address Field
                            AppTextField(
                              controller: _emailController,
                              labelText: 'Email Address',
                              hintText: 'john.doe@example.com',
                              prefixIcon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter email address';
                                }
                                final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                if (!regex.hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: AppDimensions.spaceXXL),

                            // Password Field
                            AppTextField(
                              controller: _passwordController,
                              labelText: 'Password',
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                  size: AppDimensions.iconM,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: AppDimensions.space5XL),

                            // Submit Button
                            AppButton(
                              text: 'Register',
                              isLoading: isLoading,
                              onPressed: _submitForm,
                            ),
                            SizedBox(height: AppDimensions.space3XL),

                            // Back to Login Redirect
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go(AppRouter.loginPath),
                                    child: Text(
                                      'Login',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
      context.read<AuthBloc>().add(
            RegisterSubmittedEvent(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }
}
