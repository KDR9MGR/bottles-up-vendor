import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onTabTapped(context, index),
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.home_outline),
            activeIcon: Icon(Ionicons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.calendar_outline),
            activeIcon: Icon(Ionicons.calendar),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.business_outline),
            activeIcon: Icon(Ionicons.business),
            label: 'Venue Hub',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.cash_outline),
            activeIcon: Icon(Ionicons.cash),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.menu_outline),
            activeIcon: Icon(Ionicons.menu),
            label: 'More',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/events')) return 1;
    if (location.startsWith('/clubs')) return 2;
    if (location.startsWith('/earnings')) return 3;
    if (location.startsWith('/profile') || location.startsWith('/more')) return 4;

    return 0; // Default to dashboard
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/events');
        break;
      case 2:
        context.go('/clubs');
        break;
      case 3:
        context.go('/earnings');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
} 