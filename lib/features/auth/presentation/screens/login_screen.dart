import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
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
    final outerColor = isDark ? const Color(0xFF0E1521) : const Color(0xFFF4F6F8);
    final borderColor = isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF);
    final inputBgColor = isDark ? const Color(0xFF18212F) : Colors.white;
    final inputBorderColor = isDark ? const Color(0xFF283446) : const Color(0xFFE6EAEF);
    final primaryColor = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488);
    final titleColor = isDark ? const Color(0xFFEEF2F7) : const Color(0xFF131A24);
    final subtitleColor = isDark ? const Color(0xFF98A4B4) : const Color(0xFF5C6675);
    final shadowColor = isDark ? const Color(0x66000000) : const Color(0x1E19202D);
    final focusHighlightColor = isDark ? const Color(0xFF2DD4BF).withOpacity(0.15) : const Color(0xFFD6F3EF);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0E14) : const Color(0xFFEBEDF1),
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
                                      LoginTextField(
                                        controller: _emailController,
                                        focusNode: _emailFocus,
                                        labelText: 'Email',
                                        hintText: 'john.doe@example.com',
                                        prefixIcon: Icons.mail_outline,
                                        keyboardType: TextInputType.emailAddress,
                                        titleColor: titleColor,
                                        subtitleColor: subtitleColor,
                                        inputBgColor: inputBgColor,
                                        inputBorderColor: inputBorderColor,
                                        primaryColor: primaryColor,
                                        focusHighlightColor: focusHighlightColor,
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
                                      LoginTextField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocus,
                                        labelText: 'Password',
                                        hintText: '••••••••',
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: _obscurePassword,
                                        titleColor: titleColor,
                                        subtitleColor: subtitleColor,
                                        inputBgColor: inputBgColor,
                                        inputBorderColor: inputBorderColor,
                                        primaryColor: primaryColor,
                                        focusHighlightColor: focusHighlightColor,
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
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Demo mode: Contact system administrator to reset password',
                                                ),
                                              ),
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
                                      LoginButton(
                                        isLoading: isLoading,
                                        onPressed: _submitForm,
                                        primaryColor: primaryColor,
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

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Color titleColor;
  final Color subtitleColor;
  final Color inputBgColor;
  final Color inputBorderColor;
  final Color primaryColor;
  final Color focusHighlightColor;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    required this.titleColor,
    required this.subtitleColor,
    required this.inputBgColor,
    required this.inputBorderColor,
    required this.primaryColor,
    required this.focusHighlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            color: subtitleColor,
            fontSize: AppDimensions.fontS,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.spaceM),
        Container(
          decoration: BoxDecoration(
            boxShadow: focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: focusHighlightColor,
                      blurRadius: 0,
                      offset: const Offset(0, 0),
                      spreadRadius: 3.r,
                    )
                  ]
                : null,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(
              color: titleColor,
              fontSize: AppDimensions.fontXL,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputBgColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.radiusL,
                vertical: AppDimensions.fontXL,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: subtitleColor,
                size: AppDimensions.iconS + 1,
              ),
              suffixIcon: suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: BorderSide(
                  width: 1,
                  color: inputBorderColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: BorderSide(
                  width: 1,
                  color: primaryColor,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.redAccent,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.redAccent,
                ),
              ),
              hintText: hintText,
              hintStyle: TextStyle(
                color: subtitleColor.withOpacity(0.6),
                fontSize: AppDimensions.fontXL,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}

class LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final Color primaryColor;

  const LoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryColor.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Sign in',
                style: TextStyle(
                  fontSize: AppDimensions.fontXL + 0.5,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
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
