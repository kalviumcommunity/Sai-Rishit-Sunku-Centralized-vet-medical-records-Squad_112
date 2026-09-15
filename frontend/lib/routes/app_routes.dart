import 'package:flutter/material.dart';

import '../screens/admin/admin_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/main_navigation_shell.dart';
import '../screens/pet/documents_screen.dart';
import '../screens/pet/vaccinations_screen.dart';
import '../screens/vet/add_treatment_screen.dart';
import '../screens/vet/vet_followups_screen.dart';
import '../widgets/auth_gate.dart';

/// Centralized Named Routes for VetCare.
class AppRoutes {
  // Named Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profile = '/profile';
  static const String ownerHome = '/owner_home';
  static const String petProfile = '/pet_profile';
  static const String vetSearch = '/vet_search';
  static const String vetFollowups = '/vet_followups';
  static const String addTreatment = '/add_treatment';
  static const String vaccinations = '/vaccinations';
  static const String addPet = '/add_pet';
  static const String documents = '/documents';
  static const String admin = '/admin';

  /// Named route mapping for MaterialApp.routes
  static Map<String, WidgetBuilder> get routes => {
        // AuthGate handles cold start persistence: if authenticated, skips splash & login and opens role dashboard
        splash: (context) => const AuthGate(),
        login: (context) => const LoginScreen(),
        signup: (context) => const SignupScreen(),
        // Core authenticated screens with persistent Limelight bottom navigation
        ownerHome: (context) => const MainNavigationShell(initialIndex: 0),
        petProfile: (context) => const MainNavigationShell(initialIndex: 1),
        addPet: (context) => const MainNavigationShell(initialIndex: 2),
        vetSearch: (context) => const MainNavigationShell(initialIndex: 3),
        profile: (context) => const MainNavigationShell(initialIndex: 4),
        // Secondary sub-screens / vet clinical workflows
        vetFollowups: (context) => const VetFollowupsScreen(),
        addTreatment: (context) => const AddTreatmentScreen(),
        vaccinations: (context) => const VaccinationsScreen(),
        documents: (context) => const DocumentsScreen(),
        admin: (context) => const AdminScreen(),
      };

  /// Optional onGenerateRoute for custom transitions or argument handling
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Route Not Found')),
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
