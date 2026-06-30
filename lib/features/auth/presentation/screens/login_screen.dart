import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/utils/app_snackbar.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>(),
      child: const LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginSubmittedEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.tabletBreakpoint;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Figma Exact Colors matching light & dark specs
    final outerColor = AppColors.outerCard(isDark);
    final borderColor = AppColors.cardBorder(isDark);
    final inputBgColor = AppColors.inputBackground(isDark);
    final inputBorderColor = AppColors.inputBorder(isDark);
    final primaryColor = AppColors.accent(isDark);
    final titleColor = AppColors.title(isDark);
    final subtitleColor = AppColors.subtitle(isDark);
    final shadowColor = AppColors.shadow(isDark);
    final focusHighlightColor = AppColors.focusHighlight(isDark);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0E14) : const Color(0xFFEBEDF1),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(AppRouter.dashboardPath);
          } else if (state is AuthError) {
            AppSnackbar.showError(context, state.message);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 740,
                    ),
                    child: Container(
                      width: isTablet ? 348.w : screenWidth * 0.92,
                      padding: EdgeInsets.all(AppDimensions.radiusM),
                      decoration: ShapeDecoration(
                        color: outerColor,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: borderColor,
                          ),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusPhoneOuter),
                        ),
                        shadows: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 30.r,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 720),
                            child: Container(
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: outerColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusContainer),
                                ),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 82.50.h,
                                    left: AppDimensions.paddingXL,
                                    right: AppDimensions.paddingXL,
                                    bottom: 96.50.h,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      LoginLogoHeader(
                                        primaryColor: primaryColor,
                                        titleColor: titleColor,
                                      ),
                                      SizedBox(height: AppDimensions.space6XL),
                                      WelcomeMessage(
                                        titleColor: titleColor,
                                        subtitleColor: subtitleColor,
                                      ),
                                      SizedBox(height: AppDimensions.space4XL),

                                      // Email Text Field
                                      AppTextField(
                                        controller: _emailController,
                                        focusNode: _emailFocus,
                                        labelText: 'Email',
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
                                      SizedBox(height: AppDimensions.spaceXL),

                                      // Password Text Field
                                      AppTextField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocus,
                                        labelText: 'Password',
                                        hintText: '••••••••',
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: _obscurePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: subtitleColor,
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
                                      SizedBox(height: AppDimensions.spaceM),

                                      // Forgot Password Link
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            AppSnackbar.showSuccess(
                                              context,
                                              'Demo mode: Contact system administrator to reset password',
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: Text(
                                            'Forgot password?',
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontSize: AppDimensions.fontM,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: AppDimensions.spaceXXL),

                                      // Submit Button
                                      AppButton(
                                        text: 'Sign in',
                                        isLoading: isLoading,
                                        onPressed: _submitForm,
                                      ),
                                      SizedBox(height: AppDimensions.spaceXXL),

                                      // Redirect Link
                                      LoginFooterRedirect(
                                        subtitleColor: subtitleColor,
                                        primaryColor: primaryColor,
                                        onTap: () => context.go(AppRouter.registerPath),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
}

class LoginLogoHeader extends StatelessWidget {
  final Color primaryColor;
  final Color titleColor;

  const LoginLogoHeader({
    super.key,
    required this.primaryColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: AppDimensions.sizeLogo,
          height: AppDimensions.sizeLogo,
          decoration: ShapeDecoration(
            color: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLogo),
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        SizedBox(height: AppDimensions.spaceXL),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Field',
                style: TextStyle(
                  color: titleColor,
                  fontSize: AppDimensions.fontTitleL,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.44,
                ),
              ),
              TextSpan(
                text: 'Track',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: AppDimensions.fontTitleL,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.44,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WelcomeMessage extends StatelessWidget {
  final Color titleColor;
  final Color subtitleColor;

  const WelcomeMessage({
    super.key,
    required this.titleColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: titleColor,
            fontSize: AppDimensions.fontDisplayS,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.48,
          ),
        ),
        SizedBox(height: AppDimensions.spaceS),
        Text(
          'Sign in to start your shift',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: subtitleColor,
            fontSize: AppDimensions.fontL,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}


class LoginFooterRedirect extends StatelessWidget {
  final VoidCallback onTap;
  final Color subtitleColor;
  final Color primaryColor;

  const LoginFooterRedirect({
    super.key,
    required this.onTap,
    required this.subtitleColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: subtitleColor,
            fontSize: AppDimensions.fontL,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'Register',
            style: TextStyle(
              color: primaryColor,
              fontSize: AppDimensions.fontL,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
