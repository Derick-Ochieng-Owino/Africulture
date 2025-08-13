import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:africulture/07_AIassistant/ai_assistant_modal.dart';

class AIAssistantPopup extends StatelessWidget {
  const AIAssistantPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            color: Colors.white.withOpacity(0.95), // Optional transparency
            child: const AIAssistantScreen(),
          ),
        ),
      ),
    );
  }
}