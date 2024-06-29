import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';

class CustomInput extends StatelessWidget {
  final String hintText;

  CustomInput({required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primaryColor, // Border color
        ),
        borderRadius: BorderRadius.circular(8.0), // Border radius
      ),
      child: TextField(
        maxLines: 4, // Allows multiline input
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText, // Custom hint text
        ),
      ),
    );
  }
}
