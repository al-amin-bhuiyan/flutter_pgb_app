import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/app_button.dart';
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Logo
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF0D9488),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.radar,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Field',
                                        style: TextStyle(
                                          color: Color(0xFF131A24),
                                          fontSize: 22,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.44,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Track',
                                        style: TextStyle(
                                          color: Color(0xFF0D9488),
                                          fontSize: 22,
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
                          const SizedBox(height: 26),
                          const Center(
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                color: Color(0xFF131A24),
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.48,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Center(
                            child: Text(
                              'Sign up to track coordinates and check lists',
                              style: TextStyle(
                                color: Color(0xFF5C6675),
                                fontSize: 13.5,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

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
                          const SizedBox(height: 18),

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
                          const SizedBox(height: 18),

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
                                size: 20,
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
                          const SizedBox(height: 28),

                          // Submit Button
                          AppButton(
                            text: 'Register',
                            isLoading: isLoading,
                            onPressed: _submitForm,
                          ),
                          const SizedBox(height: 24),

                          // Back to Login Redirect
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    color: Color(0xFF6B7480),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.go(AppRouter.loginPath),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Color(0xFF0D9488),
                                      fontSize: 14,
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
