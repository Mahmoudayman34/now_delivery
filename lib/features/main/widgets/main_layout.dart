import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../providers/navigation_provider.dart';
import '../screens/home_screen.dart';
// Wallet tab removed to avoid any payment-related UI during review
import '../screens/profile_screen.dart';
import '../../business/pickups/screens/pickup_screen.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final spacing = AppTheme.spacing(context);

    final screens = [
      const HomeScreen(),
      const PickupScreen(),
      const ProfileScreen(),
    ];

    // Use responsive layout for desktop/tablet vs mobile
    return Responsive.builder(
      context: context,
      mobile: _buildMobileLayout(context, ref, currentIndex, screens, spacing),
      tablet: context.isLandscape
          ? _buildTabletLandscapeLayout(context, ref, currentIndex, screens, spacing)
          : _buildMobileLayout(context, ref, currentIndex, screens, spacing),
      desktop: _buildDesktopLayout(context, ref, currentIndex, screens, spacing),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
    List<Widget> screens,
    ResponsiveSpacing spacing,
  ) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: Responsive.borderRadius(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: Responsive.borderRadius(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
          ),
          child: _buildBottomNavigation(context, ref, currentIndex),
        ),
      ),
    );
  }

  Widget _buildTabletLandscapeLayout(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
    List<Widget> screens,
    ResponsiveSpacing spacing,
  ) {
    return Scaffold(
      body: Row(
        children: [
          // Side navigation for landscape tablet
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: _buildSideNavigation(context, ref, currentIndex),
          ),
          // Main content
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
    List<Widget> screens,
    ResponsiveSpacing spacing,
  ) {
    return Scaffold(
      body: Row(
        children: [
          // Side navigation for desktop
          Container(
            width: context.responsive<double>(
              mobile: 200,
              desktop: 250,
              largeDesktop: 300,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: _buildSideNavigation(context, ref, currentIndex),
          ),
          // Main content
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: context.responsive<double>(
                  mobile: double.infinity,
                  desktop: 1200,
                  largeDesktop: 1400,
                ),
              ),
              child: IndexedStack(
                index: currentIndex,
                children: screens,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, WidgetRef ref, int currentIndex) {
    final textTheme = AppTheme.getResponsiveTextTheme(context);
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        ref.read(navigationProvider.notifier).setIndex(index);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.primaryOrange,
      unselectedItemColor: AppTheme.mediumGray,
      selectedLabelStyle: textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryOrange,
      ),
      unselectedLabelStyle: textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppTheme.mediumGray,
      ),
      elevation: 0,
      items: [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(
              Icons.home_outlined,
              size: Responsive.iconSize(context, mobile: 24, tablet: 26, desktop: 28),
            ),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(
              Icons.home,
              size: Responsive.iconSize(context, mobile: 24, tablet: 26, desktop: 28),
            ),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(
              Icons.local_shipping_outlined,
              size: Responsive.iconSize(context, mobile: 24, tablet: 26, desktop: 28),
            ),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(
              Icons.local_shipping,
              size: Responsive.iconSize(context, mobile: 24, tablet: 26, desktop: 28),
            ),
          ),
          label: 'Pickups',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(
              Icons.person_outline,
              size: Responsive.iconSize(context, mobile: 24, tablet: 26, desktop: 28),
            ),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(
              Icons.person,
              size: Responsive.iconSize(context, mobile: 24, tablet: 26, desktop: 28),
            ),
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildSideNavigation(BuildContext context, WidgetRef ref, int currentIndex) {
    final textTheme = AppTheme.getResponsiveTextTheme(context);
    final spacing = AppTheme.spacing(context);
    
    final navItems = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        index: 0,
      ),
      _NavItem(
        icon: Icons.local_shipping_outlined,
        activeIcon: Icons.local_shipping,
        label: 'Pickups',
        index: 1,
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        index: 2,
      ),
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App title/logo
          Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delivery_dining,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: spacing.md),
                if (context.isDesktop)
                  Text(
                    'Now Delivery',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
              ],
            ),
          ),
          
          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: spacing.sm),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = currentIndex == item.index;
                
                return Container(
                  margin: EdgeInsets.only(bottom: spacing.xs),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ref.read(navigationProvider.notifier).setIndex(item.index);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.md,
                          vertical: spacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppTheme.primaryOrange.withOpacity(0.1) 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected 
                                  ? AppTheme.primaryOrange 
                                  : AppTheme.mediumGray,
                              size: Responsive.iconSize(
                                context,
                                mobile: 24,
                                tablet: 26,
                                desktop: 28,
                              ),
                            ),
                            if (context.isDesktop) ...[
                              SizedBox(width: spacing.md),
                              Text(
                                item.label,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: isSelected 
                                      ? AppTheme.primaryOrange 
                                      : AppTheme.mediumGray,
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
  });
}
