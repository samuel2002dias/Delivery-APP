import 'package:flutter/material.dart';
import 'package:webapp/TextField.dart';

class IngredientTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorMsg;

  const IngredientTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.errorMsg, required String? Function(dynamic val) validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MyTextField(
        controller: controller,
        hintText: hintText,
        obscureText: false,
        keyboardType: TextInputType.text,
        errorMsg: errorMsg,
        validator: (val) {
          if (val!.isEmpty) {
            return 'Please fill in this field';
          }
          return null;
        },
      ),
    );
  }
}
