import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class EquationSolverCameraPreview extends StatelessWidget {
  const EquationSolverCameraPreview({required this.camera, super.key});

  final CameraController camera;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: camera.value.previewSize!.height,
          height: camera.value.previewSize!.width,
          child: camera.buildPreview(),
        ),
      ),
    );
  }
}
