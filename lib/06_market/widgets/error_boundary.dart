import 'package:flutter/material.dart';

class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ErrorWidgetBuilder(child: child);
  }
}

class ErrorWidgetBuilder extends StatefulWidget {
  final Widget child;

  const ErrorWidgetBuilder({super.key, required this.child});

  @override
  State<ErrorWidgetBuilder> createState() => _ErrorWidgetBuilderState();
}

class _ErrorWidgetBuilderState extends State<ErrorWidgetBuilder> {
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Something went wrong'),
              TextButton(
                onPressed: () => setState(() => hasError = false),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }

  // static void resetError() {
  //   _ErrorWidgetBuilderState().setState(() {});
  // }
}