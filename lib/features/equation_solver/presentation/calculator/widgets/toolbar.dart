import 'package:flutter/material.dart';

class CalculatorToolbar extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback onClear;
  final VoidCallback onBackspace;

  const CalculatorToolbar({
    super.key,
    required this.onUndo,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onClear,
    required this.onBackspace,
  });

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
          _toolbarIcon(icon: Icons.undo, onTap: onUndo),
          _toolbarIcon(icon: Icons.arrow_back, onTap: onMoveLeft),
          _toolbarIcon(icon: Icons.arrow_forward, onTap: onMoveRight),
          _toolbarIcon(icon: Icons.keyboard_return, onTap: onClear),
          _toolbarIcon(icon: Icons.backspace, onTap: onBackspace),
        ],
      ),
    );
  }

  Widget _toolbarIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Center(
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

