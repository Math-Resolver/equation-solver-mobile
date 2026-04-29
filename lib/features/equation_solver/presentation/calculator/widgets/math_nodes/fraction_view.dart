import 'package:flutter/material.dart';

class FractionView extends StatelessWidget {
  final Widget numerator;
  final Widget denominator;

  const FractionView({
    required this.numerator,
    required this.denominator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          numerator,
          Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            width: 42,
            height: 1.4,
            color: Colors.black87,
          ),
          denominator,
        ],
      ),
    );
  }
}
