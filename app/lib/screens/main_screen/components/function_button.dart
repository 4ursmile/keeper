import 'package:flutter/material.dart';

class FunctionButton extends StatelessWidget {
  final String icon;
  final String name;
  late double height;
  late double width;
  late double iconHeight;
  late double fontSize;
  late double spacing;
  final VoidCallback onTap;
  FunctionButton(
      {super.key,
      required this.icon,
      required this.name,
      this.height = 70,
      this.width = 40,
      this.iconHeight = 30,
      this.fontSize = 10,
      this.spacing=8,
      required this.onTap,
      });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
            padding: EdgeInsets.only(top: 10),
            height: height,
            width: width,
            child: Column(children: [
              Image.asset(icon, height: iconHeight),
              SizedBox(height: spacing),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(name, style: TextStyle(fontSize: fontSize)))
            ])));
  }
}
