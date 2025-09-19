import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = AppTheme.getResponsiveTextTheme(context);
    final spacing = AppTheme.spacing(context);

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Orders',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Responsive.builder(
        context: context,
        mobile: _buildMobileLayout(context, textTheme, spacing),
        tablet: context.isLandscape
            ? _buildTabletLandscapeLayout(context, textTheme, spacing)
            : _buildTabletPortraitLayout(context, textTheme, spacing),
        desktop: _buildDesktopLayout(context, textTheme, spacing),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards - 2x2 grid on mobile
          _buildStatsGrid(context, textTheme, spacing, 2),
          SizedBox(height: spacing.xl),
          _buildRecentOrdersSection(context, textTheme, spacing),
          SizedBox(height: 100), // Extra padding for bottom navigation
        ],
      ),
    );
  }

  Widget _buildTabletPortraitLayout(
    BuildContext context,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards - 2x2 grid on tablet portrait
          _buildStatsGrid(context, textTheme, spacing, 2),
          SizedBox(height: spacing.xl),
          _buildRecentOrdersSection(context, textTheme, spacing),
          SizedBox(height: spacing.xl),
        ],
      ),
    );
  }

  Widget _buildTabletLandscapeLayout(
    BuildContext context,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Panel - Stats
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
                SizedBox(height: spacing.lg),
                _buildStatsGrid(context, textTheme, spacing, 2),
              ],
            ),
          ),
        ),
        
        // Right Panel - Recent Orders
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: _buildRecentOrdersSection(context, textTheme, spacing),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: context.responsive<double>(
          mobile: double.infinity,
          desktop: 1200,
          largeDesktop: 1400,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel - Stats
          SizedBox(
            width: context.responsive<double>(
              mobile: 300,
              desktop: 350,
              largeDesktop: 400,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(spacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Statistics',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                  _buildStatsGrid(context, textTheme, spacing, 1),
                ],
              ),
            ),
          ),
          
          // Main Panel - Recent Orders
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(spacing.xl),
              child: _buildRecentOrdersSection(context, textTheme, spacing),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
    int crossAxisCount,
  ) {
    final statsData = [
      _StatData(
        icon: Icons.local_shipping,
        title: 'Active Orders',
        value: '12',
        color: AppTheme.primaryOrange,
      ),
      _StatData(
        icon: Icons.check_circle,
        title: 'Completed',
        value: '45',
        color: AppTheme.successGreen,
      ),
      _StatData(
        icon: Icons.schedule,
        title: 'Pending',
        value: '8',
        color: AppTheme.warningYellow,
      ),
      _StatData(
        icon: Icons.cancel,
        title: 'Cancelled',
        value: '3',
        color: Colors.red,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing.md,
        mainAxisSpacing: spacing.md,
        childAspectRatio: context.responsive<double>(
          mobile: 1.3,
          tablet: 1.4,
          desktop: 1.2,
        ),
      ),
      itemCount: statsData.length,
      itemBuilder: (context, index) {
        final stat = statsData[index];
        return _StatCard(
          icon: stat.icon,
          title: stat.title,
          value: stat.value,
          color: stat.color,
          textTheme: textTheme,
          spacing: spacing,
        );
      },
    );
  }

  Widget _buildRecentOrdersSection(
    BuildContext context,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Orders',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        SizedBox(height: spacing.md),
        
        // Orders List
        ...List.generate(10, (index) {
          return _OrderCard(
            orderId: '#ORD${1000 + index}',
            customerName: 'Customer ${index + 1}',
            status: index % 3 == 0 ? 'Delivered' : index % 3 == 1 ? 'In Transit' : 'Pending',
            amount: '\$${(25.50 + index * 5).toStringAsFixed(2)}',
            time: '${2 + index} hours ago',
            textTheme: textTheme,
            spacing: spacing,
          );
        }),
      ],
    );
  }
}

class _StatData {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatData({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final TextTheme textTheme;
  final ResponsiveSpacing spacing;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.textTheme,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Responsive.borderRadius(
          context,
          mobile: 12,
          tablet: 14,
          desktop: 16,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: context.responsive<double>(
              mobile: 8,
              tablet: 10,
              desktop: 12,
            ),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(spacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: Responsive.borderRadius(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: Responsive.iconSize(
                context,
                mobile: 20,
                tablet: 22,
                desktop: 24,
              ),
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGray,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String status;
  final String amount;
  final String time;
  final TextTheme textTheme;
  final ResponsiveSpacing spacing;

  const _OrderCard({
    required this.orderId,
    required this.customerName,
    required this.status,
    required this.amount,
    required this.time,
    required this.textTheme,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'Delivered':
        statusColor = AppTheme.successGreen;
        break;
      case 'In Transit':
        statusColor = AppTheme.primaryOrange;
        break;
      case 'Pending':
        statusColor = AppTheme.warningYellow;
        break;
      default:
        statusColor = AppTheme.mediumGray;
    }

    return Container(
      margin: EdgeInsets.only(bottom: spacing.sm),
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Responsive.borderRadius(
          context,
          mobile: 12,
          tablet: 14,
          desktop: 16,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: context.responsive<double>(
              mobile: 8,
              tablet: 10,
              desktop: 12,
            ),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  customerName,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: Responsive.borderRadius(
                      context,
                      mobile: 6,
                      tablet: 8,
                      desktop: 10,
                    ),
                  ),
                  child: Text(
                    status,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                time,
                style: textTheme.bodySmall?.copyWith(
                  color: AppTheme.mediumGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
