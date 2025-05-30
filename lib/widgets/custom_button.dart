import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor:
            WidgetStateProperty.all(const Color.fromARGB(255, 255, 255, 255)),
        backgroundColor:
            WidgetStateProperty.all(const Color.fromARGB(255, 170, 27, 183)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
        ),
      ),
    );
  }
}
