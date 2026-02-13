import 'package:email_otp_auth/email_otp_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelling_doctors/logandreg/register_page.dart';

import '../components/myappbar.dart';
import '../components/mylogregbutton.dart';
import '../components/mytextfield.dart';
class OTPVerificationPage extends StatefulWidget {
  final String selectedRole;

  const OTPVerificationPage({super.key, required this.selectedRole});

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  // controllar's declartion
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _otpFieldEnabled = false;

  // disposing of textEditingControllers
  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    Future<void> sendOtp() async {
      if (!_formKey.currentState!.validate()) return;
      try {
        // showing CircularProgressIndicator.
        showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // getting response from sendOTP Method.
        var res = await EmailOtpAuth.sendOTP(email: emailController.text);

        // poping out CircularProgressIndicator.
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // if response[message == "Email Send"] then..
        if (res["message"] == "Email Send" && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP Send Successfully ✅"),
            ),
          );
          setState(() {
            _otpFieldEnabled = true;
          });
          print("OTP SENT");
        }
        // else show Invalid Email Address.
        else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Invalid E-Mail Address ❌"),
              ),
            );
          }
        }
      }
      // error handling
      catch (error) {
        throw error.toString();
      }
    }

    Future<void> verifyOTP() async {
      // Check that the OTP field is not empty manually.
      if (otpController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter OTP")),
        );
        return;
      }
      try {
        showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        var res = await EmailOtpAuth.verifyOtp(otp: otpController.text);

        if (context.mounted) {
          Navigator.of(context).pop();
        }

        if (res["message"] == "OTP Verified" && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP verified ✅"),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterPage(selectedRole: widget.selectedRole, emailRecieved: emailController.text),
            ),
          );
        }
        // if response[message == "Invalid OTP"] then..
        else if (res["data"] == "Invalid OTP" && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid OTP ❌"),
            ),
          );
        }
        // if response[message == "OTP Expired"] then..
        else if (res["data"] == "OTP Expired" && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP Expired ⚠️"),
            ),
          );
        }
        // else return nothing.
        else {
          return;
        }
      } catch (error) {
        throw error.toString();
      }
    }

    return Scaffold(
      appBar: const MyGradientAppBar(title: 'Email Verification'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyTextField(
                          controller: emailController,
                          hintText: "E-mail",
                          icon: Icons.email_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter your Email";
                              }
                              // Simple email validation regex.
                              final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                        ),
                        const SizedBox(height: 16),
                        MyButton(
                          text: "Send OTP",
                          onPressed: sendOtp,
                        ),
                        const SizedBox(height: 20),
                        MyTextField(
                          controller: otpController,
                          hintText: "OTP",
                          icon: Icons.lock_outline_rounded,
                          enabled: _otpFieldEnabled,
                        ),
                        const SizedBox(height: 16),
                        MyButton(
                          text: "Verify OTP",
                          onPressed: verifyOTP,
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
    );
  }
}