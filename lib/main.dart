import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing/services/reservation_approval_service.dart';
import 'package:testing/services/workflow_service.dart';
import 'package:testing/services/unified_reservation_service.dart';
import 'services/today_status_service.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/resource_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B0000)),
                ),
              ),
            ),
          );
        }

        final prefs = snapshot.data as SharedPreferences;
        final token = prefs.getString('token');

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthService()),
            ChangeNotifierProvider(create: (_) => UserService()),
            ChangeNotifierProvider(create: (_) {
              final resourceService = ResourceService();
              if (token != null) {
                final cleanedToken = token.replaceAll('"', '').trim();
                resourceService.setToken(cleanedToken);
              }
              return resourceService;
            }),
            ChangeNotifierProvider(create: (_) => WorkflowService()),
            ChangeNotifierProvider(create: (_) => ReservationApprovalService()),
            ChangeNotifierProvider(create: (_) => TodayStatusService()),
            ChangeNotifierProvider(create: (context) => NotificationService()),
            ChangeNotifierProvider(
      create: (context) => AuthService(),
    ),
    ChangeNotifierProxyProvider<AuthService, UnifiedReservationService>(
      create: (context) => UnifiedReservationService(
        context.read<AuthService>(),
      ),
      update: (context, authService, previous) =>
          previous ?? UnifiedReservationService(authService),
    ),
          ],
          child: MaterialApp(
            title: 'MSEUF-CI Resource Appointment System',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B0000)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return authService.isAuthenticated 
            ? DashboardScreen() 
            : LoginScreen();
      },
    );
  }
}