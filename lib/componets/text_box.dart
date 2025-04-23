import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  const MyTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    required this.controller,
  });

  final String hintText;
  final bool obscureText;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry margin;
  final TextEditingController? controller;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(12),
          ),
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          hintText: hintText,
          isDense: true,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
          contentPadding: contentPadding,
        ),
      ),
    );
  }
}