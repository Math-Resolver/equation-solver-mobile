import 'package:flutter/material.dart';

class AbsoluteView extends StatelessWidget {
  final Widget child;

  const AbsoluteView({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('|', style: TextStyle(fontSize: 20, height: 1)),
        child,
        const Text('|', style: TextStyle(fontSize: 20, height: 1)),
      ],
    );
  }
}
