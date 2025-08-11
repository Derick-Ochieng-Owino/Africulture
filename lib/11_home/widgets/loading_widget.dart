import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PlantGrowLoading extends StatelessWidget {
  final String? message;

  const PlantGrowLoading({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Opaque dark background covering entire screen
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        // Centered Lottie animation and optional message
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Lottie.asset('assets/lottie/plant_grow.json'),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
