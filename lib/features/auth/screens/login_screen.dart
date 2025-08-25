import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../providers/supabase_auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../../shared/widgets/responsive_wrapper.dart';
import '../../../core/utils/responsive_utils.dart' as utils;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(supabaseAuthProvider.notifier)
          .signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(supabaseAuthProvider);
    final theme = Theme.of(context);

    // Listen to auth state changes
    ref.listen<String?>(authErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        ref.read(supabaseAuthProvider.notifier).clearError();
      }
    });

    // Navigate to dashboard if authenticated
    ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
      if (next) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: ResponsiveWrapper(
          centerContent: true,
          maxWidth: 500,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              utils.ResponsiveUtils.getResponsivePadding(context),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height:
                        utils.ResponsiveUtils.getResponsiveSpacing(context) *
                        1.5,
                  ),

                  // Logo and Title
                  Column(
                    children: [
                      ResponsiveBuilder(
                        builder: (context, sizingInformation) {
                          final logoSize = getValueForScreenType<double>(
                            context: context,
                            mobile: 80.0,
                            tablet: 100.0,
                            desktop: 120.0,
                          );
                          final iconSize = getValueForScreenType<double>(
                            context: context,
                            mobile: 40.0,
                            tablet: 50.0,
                            desktop: 60.0,
                          );

                          return Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SvgPicture.asset(
                              '/assets/images/app_logo_orange.svg',
                              color: Colors.black,
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: utils.ResponsiveUtils.getResponsiveSpacing(
                          context,
                        ),
                      ),
                      ResponsiveText.headlineLarge(
                        'Bottles Up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(
                        height:
                            utils.ResponsiveUtils.getResponsiveSpacing(
                              context,
                            ) *
                            0.5,
                      ),
                      ResponsiveText.titleLarge(
                        'Vendor Portal',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height:
                        utils.ResponsiveUtils.getResponsiveSpacing(context) * 2,
                  ),

                  // Welcome Text
                  ResponsiveText.headlineSmall(
                    'Welcome back!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height:
                        utils.ResponsiveUtils.getResponsiveSpacing(context) *
                        0.5,
                  ),
                  ResponsiveText.bodyLarge(
                    'Sign in to manage your events and bookings',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),

                  SizedBox(
                    height:
                        utils.ResponsiveUtils.getResponsiveSpacing(context) *
                        1.5,
                  ),

                  // Email Field
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  SizedBox(
                    height: utils.ResponsiveUtils.getResponsiveSpacing(context),
                  ),

                  // Password Field
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  SizedBox(
                    height:
                        utils.ResponsiveUtils.getResponsiveSpacing(context) *
                        0.5,
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.push('/forgot-password');
                      },
                      child: ResponsiveText.bodyMedium(
                        'Forgot Password?',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: utils.ResponsiveUtils.getResponsiveSpacing(context),
                  ),

                  // Sign In Button
                  AuthButton(
                    text: 'Sign In',
                    onPressed: _signIn,
                    isLoading: authState.isLoading,
                  ),

                  SizedBox(
                    height: utils.ResponsiveUtils.getResponsiveSpacing(context),
                  ),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ResponsiveText.bodyMedium("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          context.push('/register');
                        },
                        child: ResponsiveText.bodyMedium(
                          'Sign Up',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height:
                        utils.ResponsiveUtils.getResponsiveSpacing(context) * 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
