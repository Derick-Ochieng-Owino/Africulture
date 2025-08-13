import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String? text;
  final String? imageUrl;
  final bool isUser;

  const ChatMessage({this.text, this.imageUrl, required this.isUser, super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = isUser ? Colors.green[100] : Colors.white;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isUser
        ? const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomLeft: Radius.circular(12),
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomRight: Radius.circular(12),
    );

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
          ),
          child: imageUrl != null
              ? GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: Image.network(imageUrl!),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl!,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          )
              : Text(text ?? ""),
        ),
      ],
    );
  }
}
