import 'package:flutter/material.dart';
import 'package:travelling_doctors/pages/intern/internupload.dart';

import 'login_page.dart';


class ChoosingPage extends StatelessWidget {
  const ChoosingPage({super.key});

  void navigateToLogin(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(selectedRole: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 25, vertical: 170),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(1000, 115, 170, 187),
              Color.fromARGB(1000, 49, 73, 104),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('CHOOSE A ROLE',
              style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 30,),),
              const SizedBox(height: 30,),
              MaterialButton(
                color: const Color.fromARGB(1000,231,237,233),
                child: const Text('Patient', style: TextStyle(color: Colors.black)),
                onPressed: () => navigateToLogin(context, 'patient'),
              ),
              const SizedBox(height: 20),
              MaterialButton(
                color: Color.fromARGB(1000,231,237,233),
                child: const Text('Doctor', style: TextStyle(color: Colors.black)),
                onPressed: () => navigateToLogin(context, 'doctor'),
              ),
              const SizedBox(height: 20),
              MaterialButton(
                color: Color.fromARGB(1000,231,237,233),
                child: const Text('Intern', style: TextStyle(color: Colors.black)),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InternUploadPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}