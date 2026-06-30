import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/theme/dimensions.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.tabletBreakpoint;

    return Scaffold(
      backgroundColor: const Color(0xFFEBEDF1),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(AppRouter.dashboardPath);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
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
                          color: const Color(0xFFF4F6F8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusContainer),
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
                                      color: const Color(0xFF0D9488),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusLogo),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.radar,
                                      color: Colors.white,
                                      size: AppDimensions.space3XL + 6,
                                    ),
                                  ),
                                  SizedBox(height: AppDimensions.spaceXL),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Field',
                                          style: TextStyle(
                                            color: const Color(0xFF131A24),
                                            fontSize: AppDimensions.fontTitleL,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.44,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Track',
                                          style: TextStyle(
                                            color: const Color(0xFF0D9488),
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
                              ),
                            ),
                            SizedBox(height: AppDimensions.space6XL),
                            Center(
                              child: Text(
                                'Welcome back',
                                style: TextStyle(
                                  color: const Color(0xFF131A24),
                                  fontSize: AppDimensions.fontDisplayS,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.48,
                                ),
                              ),
                            ),
                            SizedBox(height: AppDimensions.spaceS),
                            Center(
                              child: Text(
                                'Sign in to start your shift',
                                style: TextStyle(
                                  color: const Color(0xFF5C6675),
                                  fontSize: AppDimensions.fontL,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(height: AppDimensions.space3XL),

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
                                  color: const Color(0xFF5C6675),
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
                              text: 'Sign In',
                              isLoading: isLoading,
                              onPressed: _submitForm,
                            ),
                            SizedBox(height: AppDimensions.space3XL),

                            // Create Account Redirect
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: const Color(0xFF6B7480),
                                      fontSize: AppDimensions.fontL,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go(AppRouter.registerPath),
                                    child: Text(
                                      'Register',
                                      style: TextStyle(
                                        color: const Color(0xFF0D9488),
                                        fontSize: AppDimensions.fontL,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Inter',
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
            LoginSubmittedEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }
}
