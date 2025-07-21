import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final String logoPath;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.label,
    required this.logoPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(logoPath, height: 24),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
    );
  }
}
