import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelling_doctors/logandreg/choosing_page.dart';
import 'package:travelling_doctors/pages/doctor/app_drawer.dart' as doctor_drawer;
import 'package:travelling_doctors/pages/patient/app_drawer.dart' as patient_drawer;

import 'auth-service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final session = Supabase.instance.client.auth.currentSession;
    print("Session on AuthGate init: $session"); // Debugging line

    if (session == null) {
      setState(() => isLoading = false);
      return;
    }

    final role = await AuthService().getUserRole();
    setState(() {
      userRole = role;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userRole == null) {
      return const ChoosingPage();
    } else if (userRole == 'doctor') {
      return const doctor_drawer.AppDrawer();
    } else if (userRole == 'patient') {
      return const patient_drawer.AppDrawer();
    } else {
      return const Scaffold(
        body: Center(child: Text("Unknown role. Please contact support.")),
      );
    }
  }
}
