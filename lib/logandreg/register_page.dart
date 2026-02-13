import 'package:flutter/material.dart';

import '../auth/auth-service.dart';
import '../components/myappbar.dart';
import '../components/mylogregbutton.dart';
import '../components/mytextfield.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final String selectedRole;
  final String emailRecieved;
  const RegisterPage({super.key,required this.emailRecieved, required this.selectedRole});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controllers for MyTextField
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();

  String name = '';
  String password = '';
  late String email;
  int age = 0;
  String gender = 'Male';
  String specialization = '';

  @override
  void initState() {
    super.initState();
    email = widget.emailRecieved;
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    ageController.dispose();
    specializationController.dispose();
    super.dispose();
  }

  void register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
// Retrieve values from controllers
      final String name = nameController.text;
      final String password = passwordController.text;
      final int age = int.tryParse(ageController.text) ?? 0;
      final String specialization = specializationController.text;
      final response = await _authService.signUpWithEmailPassword(
        email: widget.emailRecieved,
        password: password,
        name: name,
        age: age,
        gender: gender,
        role: widget.selectedRole,
        specialization: widget.selectedRole == 'doctor' ? specialization : null,
      );
      if (response.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginPage(selectedRole: widget.selectedRole),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration failed. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyGradientAppBar(title: 'Register (${widget.selectedRole.toUpperCase()})'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              margin: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 50),
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
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        MyTextField(
                          controller: nameController,
                          hintText: 'Enter your Name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter name';
                            }
                            // Check if name starts with a letter and has at least 5 characters
                            final regex = RegExp(r'^[A-Za-z].{4,}$');
                            if (!regex.hasMatch(value)) {
                              return 'Enter full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        MyTextField(
                          controller: passwordController,
                          hintText: 'Enter your Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        MyTextField(
                          controller: ageController,
                          hintText: 'Enter your Age',
                          icon: Icons.numbers,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter age';
                            }
                            final parsedAge = int.tryParse(value);
                            if (parsedAge == null || parsedAge <= 0) {
                              return 'Enter a valid age';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: gender,
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            labelText: 'Gender',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              gender = value ?? 'Male';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (widget.selectedRole == 'doctor') ...[
                          MyTextField(
                            controller: specializationController,
                            hintText: 'Enter your Specialization',
                            icon: Icons.medical_services_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter specialization';
                              }
                              if (value.trim().length < 3) {
                                return 'Specialization must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 20),
                        MyButton(
                          text: "Register",
                          onPressed: register,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );  }
}
