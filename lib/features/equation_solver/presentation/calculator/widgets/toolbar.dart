import 'package:flutter/material.dart';

class CalculatorToolbar extends StatelessWidget {
  const CalculatorToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "abc",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          _toolbarIcon(Icons.undo),
          _toolbarIcon(Icons.arrow_back),
          _toolbarIcon(Icons.arrow_forward),
          _toolbarIcon(Icons.keyboard_return),
          _toolbarIcon(Icons.backspace),
        ],
      ),
    );
  }

  Widget _toolbarIcon(IconData icon) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Icon(icon, size: 18),
      ),
    );
  }
}

