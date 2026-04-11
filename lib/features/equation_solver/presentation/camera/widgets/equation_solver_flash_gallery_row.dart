import 'package:flutter/material.dart';

class EquationSolverFlashGalleryRow extends StatelessWidget {
  const EquationSolverFlashGalleryRow({
    required this.flashEnabled,
    required this.onFlashToggle,
    required this.onGalleryPick,
    super.key,
  });

  final bool flashEnabled;
  final VoidCallback onFlashToggle;
  final VoidCallback onGalleryPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.photo_library, color: Colors.white),
          onPressed: onGalleryPick,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 40),
        IconButton(
          icon: Icon(
            Icons.flash_on,
            color: flashEnabled ? Colors.yellow : Colors.white,
          ),
          onPressed: onFlashToggle,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
