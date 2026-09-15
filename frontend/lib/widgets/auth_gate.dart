import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/admin/admin_screen.dart';
import '../screens/main_navigation_shell.dart';
import '../screens/splash/splash_screen.dart';
import '../services/auth_service.dart';

/// Persistent Auth State Gate (Day 4)
/// Ensures auth state persists across app cold starts:
/// - If a valid session exists on cold start: skips splash & login entirely and lands directly on the role dashboard.
/// - If unauthenticated: displays the SplashScreen which performs the initial branding flow and routes to LoginScreen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // If already authenticated on cold start, land directly on role dashboard with bottom navigation
    if (authService.isAuthenticated) {
      switch (authService.userRole) {
        case 'vet':
          return const MainNavigationShell(initialIndex: 3);
        case 'admin':
          return const AdminScreen();
        case 'owner':
        default:
          return const MainNavigationShell(initialIndex: 0);
      }
    }

    // Unauthenticated cold start: show splash flow
    return const SplashScreen();
  }
}
