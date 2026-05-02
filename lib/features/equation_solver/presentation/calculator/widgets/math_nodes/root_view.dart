import 'package:flutter/material.dart';

class RootView extends StatelessWidget {
  final Widget child;

  const RootView({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 2),
          child: Text('√', style: TextStyle(fontSize: 20, height: 1)),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: 1.2, color: Colors.black87),
            ),
          ),
          padding: const EdgeInsets.only(top: 3, left: 3, right: 2),
          child: child,
        ),
      ],
    );
  }
}
