import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../../../shared/widgets/responsive_wrapper.dart';
import '../../../core/utils/responsive_utils.dart' as utils;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: ResponsiveText.titleLarge(
          'Bottles Up Vendor',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications - Coming Soon')),
              );
            },
            icon: const Icon(Ionicons.notifications_outline),
          ),
        ],
      ),
      body: dashboardData.when(
        data: (data) => _buildDashboardContent(context, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Ionicons.warning_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              ResponsiveText.titleLarge(
                'Unable to load dashboard',
              ),
              const SizedBox(height: 8),
              ResponsiveText.bodyMedium(
                'Please check your connection and try again',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.refresh(dashboardProvider),
                icon: const Icon(Ionicons.refresh_outline),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardData data) {
    final theme = Theme.of(context);
    
    return ResponsiveWrapper(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(utils.ResponsiveUtils.getResponsivePadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Welcome Section
          ResponsiveContainer(
            decoration: AppTheme.darkContainerDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Ionicons.storefront_outline,
                      color: theme.colorScheme.primary,
                      size: utils.ResponsiveUtils.getResponsiveIconSize(context),
                    ),
                    SizedBox(width: utils.ResponsiveUtils.getResponsiveSpacing(context) * 0.75),
                    Expanded(
                      child: ResponsiveText.headlineSmall(
                        'Welcome to Bottles Up Vendor!',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 0.75),
                ResponsiveText.bodyLarge(
                  'Manage your events, inventory, and bookings efficiently',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 1.5),
          
          // Stats Cards
          ResponsiveText.titleLarge(
            'Business Overview',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context)),
          
          ResponsiveGrid(
            children: [
              _buildStatCard(
                context,
                icon: Ionicons.calendar_outline,
                title: 'Total Events',
                value: data.totalEvents.toString(),
                subtitle: '${data.upcomingEvents} upcoming',
                color: theme.colorScheme.primary,
              ),
              _buildStatCard(
                context,
                icon: Ionicons.bookmark_outline,
                title: 'Total Bookings',
                value: data.totalBookings.toString(),
                subtitle: 'This month',
                color: Colors.green,
              ),
              _buildStatCard(
                context,
                icon: Ionicons.cube_outline,
                title: 'Inventory Items',
                value: data.inventoryCount.toString(),
                subtitle: '${data.featuredBottles} featured',
                color: Colors.amber,
              ),
              _buildStatCard(
                context,
                icon: Ionicons.trending_up_outline,
                title: 'Revenue',
                value: '\$${data.totalRevenue.toStringAsFixed(0)}',
                subtitle: 'This month',
                color: Colors.purple,
              ),
            ],
          ),
          
          SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 2),
          
          // Quick Actions
          ResponsiveText.titleLarge(
            'Quick Actions',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context)),
          
          ResponsiveGrid(
            childAspectRatio: getValueForScreenType<double>(
              context: context,
              mobile: 1.3,
              tablet: 1.4,
              desktop: 1.5,
            ),
            children: [
              _buildActionCard(
                context,
                icon: Ionicons.add_circle_outline,
                title: 'Create Event',
                subtitle: 'Add new event',
                onTap: () => context.go('/events/create'),
              ),
              _buildActionCard(
                context,
                icon: Ionicons.layers_outline,
                title: 'Manage Inventory',
                subtitle: 'Update bottles',
                onTap: () => context.go('/inventory'),
              ),
              _buildActionCard(
                context,
                icon: Ionicons.people_outline,
                title: 'View Bookings',
                subtitle: 'Customer orders',
                onTap: () => context.go('/bookings'),
              ),
              _buildActionCard(
                context,
                icon: Ionicons.analytics_outline,
                title: 'Analytics',
                subtitle: 'View reports',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analytics - Coming Soon')),
                  );
                },
              ),
            ],
          ),
          
          SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 2.5),
        ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return ResponsiveContainer(
      decoration: AppTheme.darkCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: utils.ResponsiveUtils.getResponsiveIconSize(context),
              ),
              ResponsiveText.headlineMedium(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 0.5),
          ResponsiveText.titleSmall(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 0.25),
          ResponsiveText.bodySmall(
            subtitle,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final iconContainerSize = getValueForScreenType<double>(
      context: context,
      mobile: 48.0,
      tablet: 52.0,
      desktop: 56.0,
    );
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ResponsiveContainer(
        decoration: AppTheme.darkCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: utils.ResponsiveUtils.getResponsiveIconSize(context),
              ),
            ),
            SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context)),
            ResponsiveText.titleSmall(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 0.25),
            ResponsiveText.bodySmall(
              subtitle,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 