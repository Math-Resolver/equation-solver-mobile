import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String label;
  final ButtonType type;
  final VoidCallback onTap;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;

    switch (type) {
      case ButtonType.number:
        bg = const Color(0xFFDCEBFA); // azul claro
        break;
      case ButtonType.operator:
        bg = Colors.white;
        break;
      case ButtonType.function:
        bg = const Color(0xFFF2F2F2);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}


enum ButtonType {
  number,
  operator,
  function,
}