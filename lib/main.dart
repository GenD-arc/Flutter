import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testing/services/reservation_approval_service.dart';
import 'package:testing/services/reservation_status_service.dart';
import 'package:testing/services/workflow_service.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/resource_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) => ResourceService()),
        ChangeNotifierProvider(create: (_) => WorkflowService()),
        ChangeNotifierProvider(create: (_) => ReservationApprovalService()),
        ChangeNotifierProvider(create: (_) => ReservationStatusService()),
      ],
      child: MaterialApp(
        title: 'MSEUF-CI Resource Appointment System',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        print('🔍 AuthWrapper rebuild - isLoading: ${authService.isLoading}, isAuthenticated: ${authService.isAuthenticated}');
        
        // Only switch based on authentication status
        return authService.isAuthenticated 
            ? DashboardScreen() 
            : LoginScreen();
      },
    );
  }
}