import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final bool enabled;
  final String? Function(String?)? validator;

  const MyTextField({
    Key? key,
    this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.validator,
    this.enabled =true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: const Offset(3, 3),
            blurRadius: 6,
            color: Colors.grey.shade400,
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 16, left: 12),
          prefixIcon: Icon(icon),
          hintText: hintText,
          enabled: enabled,
        ),
      ),
    );
  }
}