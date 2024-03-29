import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    Key? key,
    required this.onSaved,
    required this.regularExpression,
    required this.hintText,
    required this.obscureText,
  }) : super(key: key);

  final Function(String) onSaved;
  final String regularExpression;
  final String hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
          fillColor: const Color.fromRGBO(220, 220, 220, 1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.white,
          )),
      style: const TextStyle(
        color: Colors.white,
      ),
      cursorColor: Colors.white,
      obscureText: obscureText,
      onSaved: (_value) => onSaved(_value!),
      validator: (_value) => RegExp(regularExpression).hasMatch(_value!)
          ? null
          : 'Enter a valid value.',
    );
  }
}

class CustomEmailField extends StatelessWidget {
  const CustomEmailField({
    Key? key,
    required this.onSaved,
    required this.regularExpression,
    required this.hintText,
    required this.obscureText,
  }) : super(key: key);

  final Function(String) onSaved;
  final String regularExpression;
  final String hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
          fillColor: const Color.fromRGBO(220, 220, 220, 1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.white,
          )),
      style: const TextStyle(
        color: Colors.white,
      ),
      cursorColor: Colors.white,
      obscureText: obscureText,
      onSaved: (_value) => onSaved(_value!),
      validator: (_value) => RegExp(regularExpression).hasMatch(_value!)
          ? null
          : 'Enter a valid email address.',
    );
  }
}
