import 'package:flutter/material.dart';
import 'package:travelling_doctors/pages/doctor/app_drawer.dart' as doctor_drawer;
import 'package:travelling_doctors/pages/patient/app_drawer.dart' as patient_drawer;
import '../auth/auth-service.dart';
import '../auth/auth_gate.dart';
import '../components/myappbar.dart';
import '../components/mylogregbutton.dart';
import '../components/mytextfield.dart';
import 'otp_verification.dart';

class LoginPage extends StatefulWidget {
  final String selectedRole;
  const LoginPage({Key? key, required this.selectedRole}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();


  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confipasswordController = TextEditingController();

  void login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Retrieve the values directly from the controllers.
      final email = emailController.text;
      final password = passwordController.text;
      final confirmPassword = confipasswordController.text;
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Passwords do not match")));
        return;
      }
      try {
        final response = await _authService.signInWithEmailPassword(email, password);
        print("Login Successful: ${response.session?.user?.id}"); // Debugging line
        if (response.session != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthGate()),
          );
        }      }
      catch(e){
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error : $e")));
        }
      }

    }
  }

  void navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OTPVerificationPage(selectedRole: widget.selectedRole),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyGradientAppBar(title: 'Login (${widget.selectedRole.toUpperCase()})'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Container(
              margin: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 110),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(1000, 115, 170, 187),
                    Color.fromARGB(1000, 49, 73, 104),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15), // Match card's default shape
              ),
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyTextField(
                        controller: emailController,
                        hintText: 'Enter your Email',
                        icon: Icons.email_outlined,
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Enter your Email' : null,
                      ),
                      const SizedBox(height: 16),
                      MyTextField(
                        controller: passwordController,
                        hintText: 'Enter your Password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Enter your Password' : null,
                      ),
                      const SizedBox(height: 16),
                      MyTextField(
                        controller: confipasswordController,
                        hintText: 'Confirm your Password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Confirm your Password' : null,
                      ),
                      const SizedBox(height: 20),
                      MyButton(
                        text: "Login",
                        onPressed: login,
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black
                            ),
                          ),
                          const SizedBox(width: 10,),
                          InkWell(
                            onTap: (){
                              navigateToRegister();
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
