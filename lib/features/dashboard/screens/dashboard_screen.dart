import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:intl/intl.dart';

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
          'Dashboard',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications - Coming Soon')),
              );
            },
            icon: const Icon(Ionicons.notifications_outline),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: dashboardData.when(
        data: (data) => _buildDashboardContent(context, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorState(context, error, ref),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, dynamic data) {
    final theme = Theme.of(context);

    return ResponsiveWrapper(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          utils.ResponsiveUtils.getResponsivePadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 2,
            ),

            // Key Metrics
            _buildKeyMetricsSection(context, data),

            SizedBox(
              height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 2,
            ),

            // Quick Actions
            _buildQuickActionsSection(context),

            SizedBox(
              height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 2,
            ),

            // Recent Activity
            _buildRecentActivitySection(context, data),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveContainer(
      decoration: AppTheme.darkContainerDecoration,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Ionicons.storefront_outline,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          SizedBox(width: utils.ResponsiveUtils.getResponsiveSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText.headlineSmall(
                  'Welcome back!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height:
                      utils.ResponsiveUtils.getResponsiveSpacing(context) * 0.5,
                ),
                ResponsiveText.bodyMedium(
                  'Here\'s what\'s happening with your business today',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsSection(BuildContext context, dynamic data) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleLarge(
          'Key Metrics',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context)),

        ResponsiveGrid(
          children: [
            _buildMetricCard(
              context,
              icon: Ionicons.calendar_outline,
              title: 'Active Events',
              value: data.activeEvents.toString(),
              subtitle: '${data.upcomingEvents} upcoming',
              color: theme.colorScheme.primary,
              trend: data.upcomingEvents > 0 ? '+${data.upcomingEvents}' : null,
            ),
            _buildMetricCard(
              context,
              icon: Ionicons.trending_up_outline,
              title: 'Monthly Revenue',
              value: '\$${NumberFormat('#,###').format(data.monthlyRevenue)}',
              subtitle: 'This month',
              color: Colors.green,
              trend:
                  data.monthlyRevenue > 0
                      ? '+${((data.monthlyRevenue / (data.monthlyRevenue - 1000)) * 100 - 100).toStringAsFixed(1)}%'
                      : null,
            ),
            _buildMetricCard(
              context,
              icon: Ionicons.people_outline,
              title: 'Total Bookings',
              value: data.totalBookings.toString(),
              subtitle: '${data.confirmedBookings} confirmed',
              color: Colors.blue,
              trend:
                  data.confirmedBookings > 0
                      ? '${((data.confirmedBookings / data.totalBookings) * 100).toStringAsFixed(0)}% confirmed'
                      : null,
            ),
            _buildMetricCard(
              context,
              icon: Ionicons.cube_outline,
              title: 'Inventory',
              value: data.inventoryCount.toString(),
              subtitle: '${data.lowStockItems} low stock',
              color: Colors.amber,
              trend:
                  data.lowStockItems > 0
                      ? '${data.lowStockItems} alerts'
                      : null,
              isAlert: data.lowStockItems > 0,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleLarge(
          'Quick Actions',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context)),

        ResponsiveGrid(
          childAspectRatio: getValueForScreenType<double>(
            context: context,
            mobile: 1.4,
            tablet: 1.6,
            desktop: 1.8,
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
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, dynamic data) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleLarge(
          'Recent Activity',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: utils.ResponsiveUtils.getResponsiveSpacing(context)),

        ResponsiveContainer(
          decoration: AppTheme.darkCardDecoration,
          child: Column(
            children: [
              _buildActivityItem(
                context,
                icon: Ionicons.calendar_outline,
                title: 'Last Event Created',
                subtitle:
                    data.lastEventDate != null
                        ? DateFormat('MMM dd, yyyy').format(data.lastEventDate!)
                        : 'No events yet',
                color: theme.colorScheme.primary,
              ),
              if (data.lastEventDate != null)
                Divider(color: theme.colorScheme.outline.withOpacity(0.1)),
              _buildActivityItem(
                context,
                icon: Ionicons.people_outline,
                title: 'Last Booking',
                subtitle:
                    data.lastBookingDate != null
                        ? DateFormat(
                          'MMM dd, yyyy',
                        ).format(data.lastBookingDate!)
                        : 'No bookings yet',
                color: Colors.blue,
              ),
              if (data.lastBookingDate != null)
                Divider(color: theme.colorScheme.outline.withOpacity(0.1)),
              _buildActivityItem(
                context,
                icon: Ionicons.cube_outline,
                title: 'Last Inventory Update',
                subtitle:
                    data.lastInventoryUpdate != null
                        ? DateFormat(
                          'MMM dd, yyyy',
                        ).format(data.lastInventoryUpdate!)
                        : 'No updates yet',
                color: Colors.amber,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    String? trend,
    bool isAlert = false,
  }) {
    final theme = Theme.of(context);

    return ResponsiveContainer(
      decoration: AppTheme.darkCardDecoration.copyWith(
        border:
            isAlert
                ? Border.all(
                  color: theme.colorScheme.error.withOpacity(0.3),
                  width: 1,
                )
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isAlert
                            ? theme.colorScheme.error.withOpacity(0.1)
                            : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isAlert ? theme.colorScheme.error : color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 0.75,
          ),
          ResponsiveText.headlineMedium(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color:
                  isAlert
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(
            height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 0.25,
          ),
          ResponsiveText.titleSmall(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: utils.ResponsiveUtils.getResponsiveSpacing(context) * 0.25,
          ),
          ResponsiveText.bodySmall(
            subtitle,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ResponsiveContainer(
        decoration: AppTheme.darkCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 28),
            ),
            SizedBox(
              height: utils.ResponsiveUtils.getResponsiveSpacing(context),
            ),
            ResponsiveText.titleSmall(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height:
                  utils.ResponsiveUtils.getResponsiveSpacing(context) * 0.25,
            ),
            ResponsiveText.bodySmall(
              subtitle,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: utils.ResponsiveUtils.getResponsiveSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText.titleSmall(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height:
                      utils.ResponsiveUtils.getResponsiveSpacing(context) *
                      0.25,
                ),
                ResponsiveText.bodySmall(
                  subtitle,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error, WidgetRef ref) {
    final theme = Theme.of(context);

    return Center(
      child: ResponsiveWrapper(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Ionicons.warning_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            ResponsiveText.headlineSmall(
              'Unable to load dashboard',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ResponsiveText.bodyMedium(
              'Please check your connection and try again',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => ref.refresh(dashboardProvider),
              icon: const Icon(Ionicons.refresh_outline),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
