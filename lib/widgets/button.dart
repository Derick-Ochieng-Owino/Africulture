import 'package:flutter/material.dart';

typedef VoidCallback = void Function();

class CustomButton extends StatelessWidget {
  final Widget child;
  final Color color;
  final Function() onPressed; // ← replaces VoidCallback

  const CustomButton({
    super.key,
    required this.child,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(child: child),
      ),
    );
  }
}
