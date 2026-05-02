import 'package:flutter/material.dart';

class ParenthesesView extends StatelessWidget {
  final Widget child;

  const ParenthesesView({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('(', style: TextStyle(fontSize: 20, height: 1)),
        child,
        const Text(')', style: TextStyle(fontSize: 20, height: 1)),
      ],
    );
  }
}
