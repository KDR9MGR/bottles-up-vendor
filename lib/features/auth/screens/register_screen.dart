import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ionicons/ionicons.dart';

import '../providers/supabase_auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../../shared/widgets/responsive_wrapper.dart';
import '../../../core/utils/responsive_utils.dart' as utils;
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(supabaseAuthProvider.notifier).register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        businessName: _businessNameController.text.trim().isEmpty 
            ? null 
            : _businessNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
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
        if (next == 'DATABASE_SETUP_REQUIRED') {
          // Navigate to database setup screen
          context.go('/database-setup');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: ResponsiveText.titleLarge(
          'Create Account',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            // For desktop, use a split layout with image/info on left, form on right
            if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
              return _buildDesktopLayout(context, theme, authState);
            }
            // For mobile/tablet, use traditional single column layout
            else {
              return _buildMobileLayout(context, theme, authState);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme, dynamic authState) {
    return Row(
      children: [
        // Left side - Branding and info
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.wine_bar,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Join Bottles Up',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 42,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Start managing your events, inventory, and bookings with our comprehensive vendor platform.',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 20,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Features list
                  ...['Event Management', 'Inventory Tracking', 'Booking System', 'Analytics Dashboard']
                      .map((feature) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Ionicons.checkmark_circle,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  feature,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          ),
        ),
        
        // Right side - Form
        Expanded(
          flex: 1,
          child: Container(
            color: theme.scaffoldBackgroundColor,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _buildForm(context, theme, authState),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme, dynamic authState) {
    return ResponsiveWrapper(
      centerContent: true,
      maxWidth: 500,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(utils.ResponsiveUtils.getResponsivePadding(context)),
        child: Column(
          children: [
            // Mobile header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(utils.ResponsiveUtils.getResponsiveCardPadding(context)),
              decoration: AppTheme.darkContainerDecoration,
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.wine_bar,
                      size: 40,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context)),
                  ResponsiveText.headlineSmall(
                    'Join Bottles Up',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 0.5),
                  ResponsiveText.bodyLarge(
                    'Create your vendor account to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 1.5),
            
            _buildForm(context, theme, authState),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme, dynamic authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form header (desktop only)
          ResponsiveBuilder(
            builder: (context, sizingInformation) {
              if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your account',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your details to get started',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Name and Email row for desktop
          ResponsiveBuilder(
            builder: (context, sizingInformation) {
              if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
                return Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          if (value.trim().split(' ').length < 2) {
                            return 'Please enter your first and last name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile layout - stacked fields
                return Column(
                  children: [
                    AuthTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (value.trim().split(' ').length < 2) {
                          return 'Please enter your first and last name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context)),
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ],
                );
              }
            },
          ),
          
          SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context)),
          
          // Business Name and Phone row for desktop
          ResponsiveBuilder(
            builder: (context, sizingInformation) {
              if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
                return Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        controller: _businessNameController,
                        label: 'Business Name (Optional)',
                        hintText: 'Your business or organization name',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AuthTextField(
                        controller: _phoneController,
                        label: 'Phone Number (Optional)',
                        keyboardType: TextInputType.phone,
                        hintText: '+1 (555) 123-4567',
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    AuthTextField(
                      controller: _businessNameController,
                      label: 'Business Name (Optional)',
                      hintText: 'Your business or organization name',
                    ),
                    SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context)),
                    AuthTextField(
                      controller: _phoneController,
                      label: 'Phone Number (Optional)',
                      keyboardType: TextInputType.phone,
                      hintText: '+1 (555) 123-4567',
                    ),
                  ],
                );
              }
            },
          ),
          
          SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context)),
          
          // Password and Confirm Password row for desktop
          ResponsiveBuilder(
            builder: (context, sizingInformation) {
              if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
                return Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AuthTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context)),
                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          
          SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 2),
          
          // Register Button
          AuthButton(
            text: 'Create Account',
            onPressed: _register,
            isLoading: authState.isLoading,
          ),
          
          SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 1.5),
          
          // Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ResponsiveText.bodyMedium(
                'Already have an account? ',
              ),
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: ResponsiveText.bodyMedium(
                  'Sign In',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 2.5),
        ],
      ),
    );
  }
}