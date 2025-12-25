import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/supabase_auth_provider.dart';
import '../providers/profile_stats_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorUser = ref.watch(currentVendorUserProvider);
    final supabaseUser = ref.watch(currentUserProvider);
    final authState = ref.watch(supabaseAuthProvider);
    final profileStatsAsync = ref.watch(profileStatsProvider);
    final theme = Theme.of(context);

    // Create fallback vendor user from Supabase Auth if database data is not available
    VendorUser? displayUser = vendorUser;
    if (vendorUser == null && supabaseUser != null) {
      displayUser = VendorUser(
        id: supabaseUser.id,
        email: supabaseUser.email ?? 'Unknown Email',
        phone: supabaseUser.userMetadata?['phone'],
        businessName: supabaseUser.userMetadata?['business_name'] ?? 'Bottles Up Vendor',
        logoUrl: supabaseUser.userMetadata?['avatar_url'],
        onboardingCompleted: false,
        twoFaEnabled: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        role: supabaseUser.userMetadata?['vendor_type'] ?? 'staff',
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming Soon')),
              );
            },
            icon: const Icon(Ionicons.settings_outline),
          ),
        ],
      ),
      body: displayUser == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading profile...',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (authState.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Ionicons.warning_outline,
                            color: theme.colorScheme.error,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Profile Load Error',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            authState.error!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile status indicator if using fallback data
                  if (vendorUser == null) 
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Ionicons.information_circle_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Profile data is being synchronized from Firebase Auth',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.darkContainerDecoration,
                    child: Column(
                      children: [
                        // Avatar with edit option
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 3,
                                ),
                              ),
                              child: displayUser.logoUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(47),
                                      child: Image.network(
                                        displayUser.logoUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Ionicons.person,
                                      size: 50,
                                      color: theme.colorScheme.primary,
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Edit Photo - Coming Soon')),
                                    );
                                  },
                                  icon: Icon(
                                    Ionicons.camera,
                                    size: 16,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Business Name and Email
                        Text(
                          displayUser.businessName ?? displayUser.email.split('@')[0],
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        
                        Text(
                          displayUser.email,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        if (displayUser.businessName != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Ionicons.storefront,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  displayUser.businessName!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 20),
                        
                        // Quick Stats
                        profileStatsAsync.when(
                          data: (stats) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildQuickStat(
                                context,
                                icon: Ionicons.calendar,
                                label: 'Events',
                                value: stats.totalEvents.toString(),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                              _buildQuickStat(
                                context,
                                icon: Ionicons.cube,
                                label: 'Items',
                                value: stats.totalInventoryItems.toString(),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                              _buildQuickStat(
                                context,
                                icon: Ionicons.star,
                                label: 'Rating',
                                value: stats.averageRating > 0
                                    ? stats.averageRating.toStringAsFixed(1)
                                    : 'N/A',
                              ),
                            ],
                          ),
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (_, __) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildQuickStat(
                                context,
                                icon: Ionicons.calendar,
                                label: 'Events',
                                value: '0',
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                              _buildQuickStat(
                                context,
                                icon: Ionicons.cube,
                                label: 'Items',
                                value: '0',
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                              _buildQuickStat(
                                context,
                                icon: Ionicons.star,
                                label: 'Rating',
                                value: 'N/A',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  _buildSection(
                    context,
                    'Quick Actions',
                    [
                      _buildActionTile(
                        context,
                        icon: Ionicons.create_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your information',
                        onTap: () {
                          context.push('/profile/edit');
                        },
                      ),
                      _buildActionTile(
                        context,
                        icon: Ionicons.business_outline,
                        title: 'Business Details',
                        subtitle: 'Manage business info',
                        onTap: () {
                          context.push('/profile/business');
                        },
                      ),
                      _buildActionTile(
                        context,
                        icon: Ionicons.card_outline,
                        title: 'Payment Methods',
                        subtitle: 'Manage payment options',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Payment Methods - Coming Soon')),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Account Settings
                  _buildSection(
                    context,
                    'Account Settings',
                    [
                      _buildActionTile(
                        context,
                        icon: Ionicons.lock_closed_outline,
                        title: 'Security',
                        subtitle: 'Password & 2FA',
                        onTap: () {
                          context.push('/profile/security');
                        },
                      ),
                      _buildActionTile(
                        context,
                        icon: Ionicons.notifications_outline,
                        title: 'Notifications',
                        subtitle: 'Manage your alerts',
                        onTap: () {
                          context.push('/profile/notifications');
                        },
                      ),
                      _buildActionTile(
                        context,
                        icon: Ionicons.shield_checkmark_outline,
                        title: 'Privacy',
                        subtitle: 'Data & privacy settings',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Privacy Settings - Coming Soon')),
                          );
                        },
                      ),
                      _buildActionTile(
                        context,
                        icon: Ionicons.language_outline,
                        title: 'Language & Region',
                        subtitle: 'English (US)',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Language Settings - Coming Soon')),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Support & Legal
                  _buildSection(
                    context,
                    'Support & Legal',
                    [
                      _buildActionTile(
                        context,
                        icon: Ionicons.help_circle_outline,
                        title: 'Help Center',
                        subtitle: 'FAQs & support',
                        onTap: () {
                          context.push('/support/help');
                        },
                      ),
                      _buildActionTile(
                        context,
                        icon: Ionicons.chatbubble_outline,
                        title: 'Contact Support',
                        subtitle: 'Get help from our team',
                        onTap: () {
                          context.push('/support/contact');
                        },
                      ),
                      _buildActionTile(
                        context,
                        icon: Ionicons.document_text_outline,
                        title: 'Terms of Service',
                        subtitle: 'Legal terms & conditions',
                        onTap: () {
                          context.push('/legal/terms');
                        },
                      ),
                      _buildActionTile(
                        context,
                        icon: Ionicons.shield_outline,
                        title: 'Privacy Policy',
                        subtitle: 'How we protect your data',
                        onTap: () {
                          context.push('/legal/privacy');
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Account Status (Onboarding Status)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.darkCardDecoration,
                    child: Row(
                      children: [
                        Icon(
                          displayUser.onboardingCompleted
                              ? Ionicons.checkmark_circle
                              : Ionicons.time_outline,
                          color: displayUser.onboardingCompleted
                              ? Colors.green
                              : Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayUser.onboardingCompleted
                                    ? 'Setup Complete'
                                    : 'Setup Pending',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayUser.onboardingCompleted
                                    ? 'Your account is fully set up'
                                    : 'Complete setup to access all features',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!displayUser.onboardingCompleted)
                          FilledButton(
                            onPressed: () {
                              if (displayUser != null) {
                                // Navigate to onboarding based on role
                                final role = displayUser.role;
                                final onboardingRoute = switch (role) {
                                  'venue_owner' => '/onboarding/venue',
                                  'organizer' => '/onboarding/organizer',
                                  'promoter' => '/onboarding/promoter',
                                  _ => '/onboarding/staff',
                                };
                                context.push(onboardingRoute);
                              }
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text('Verify'),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // About
                  Container(
                    decoration: AppTheme.darkCardDecoration,
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Ionicons.information_circle_outline,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'About Bottles Up',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Version 1.0.0 • App info',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Icon(
                        Ionicons.chevron_forward,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      onTap: () {
                        context.push('/about');
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign Out Button
                  SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: authState.isLoading
                          ? null
                          : () => _showSignOutDialog(context, ref),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: authState.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.error,
                                ),
                              ),
                            )
                          : Icon(
                              Ionicons.log_out_outline,
                              color: theme.colorScheme.error,
                            ),
                      label: Text(
                        'Sign Out',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppTheme.darkCardDecoration,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Ionicons.chevron_forward,
        color: theme.colorScheme.onSurfaceVariant,
        size: 18,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Icon(
          Ionicons.log_out_outline,
          color: theme.colorScheme.error,
          size: 32,
        ),
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    
    if (shouldSignOut == true) {
      await ref.read(supabaseAuthProvider.notifier).signOut();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
} 