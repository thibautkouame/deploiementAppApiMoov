
import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final Color textColor;
  final BorderRadiusGeometry borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 200,
    this.height = 56,
    this.textColor = Colors.black, // Default text color is black
    this.borderRadius = const BorderRadius.all(Radius.circular(8)), // Default border radius
    this.fontSize = 18,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3AE374),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius, // Use the modifiable border radius
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor, // Use the modifiable text color
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}

