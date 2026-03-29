import 'package:flutter/material.dart';

class CaptureButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;

  const CaptureButtonWidget({this.onPressed});
  
  @override
  Widget build(BuildContext context) {
    return Padding( 
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: onPressed, 
        child: const Text("Capturar"),
        ),
      );
  }
}