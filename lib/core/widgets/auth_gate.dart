import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alslat_aalnabi/features/home/presentation/pages/home_page.dart';
import 'package:alslat_aalnabi/features/admin/presentation/providers/admin_provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (mounted) {
      await context.read<AdminProvider>().checkAdminStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
