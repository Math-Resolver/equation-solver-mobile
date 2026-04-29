import 'package:flutter/material.dart';

class PowerView extends StatelessWidget {
  final Widget base;
  final Widget exponent;

  const PowerView({
    required this.base,
    required this.exponent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        base,
        Transform.translate(
          offset: const Offset(0, -8),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 12),
            child: exponent,
          ),
        ),
      ],
    );
  }
}
