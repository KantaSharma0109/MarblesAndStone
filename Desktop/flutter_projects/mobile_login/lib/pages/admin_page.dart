import 'package:flutter/material.dart';
import 'package:mobile_login/controllers/auth_service.dart';
import 'package:mobile_login/pages/login_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AdminPage"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to Admin page"),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
                onPressed: () {
                  AuthService.logout();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                },
                child: const Text("Logout"))
          ],
        ),
      ),
    );
  }
}
