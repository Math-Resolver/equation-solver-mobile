import 'package:camera/camera.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/equation_solver_camera_controller.dart';
import 'package:flutter/material.dart';

class EquationSolverCameraPage extends StatefulWidget {
  const EquationSolverCameraPage({
    required this.controller,
    super.key
  });

  final EquationSolverCameraController controller;

  @override
  State<EquationSolverCameraPage> createState() => _EquationSolverCameraPageState();
} 

class _EquationSolverCameraPageState extends State<EquationSolverCameraPage> {
  late final controller = widget.controller;
  String? result;

  @override
  void initState() {
    super.initState();
    controller.initCamera().then((_) {
      setState(() { });
    });
  }
  
  @override
  Widget build(BuildContext) {
    final camera = controller.cameraController;
    final isCameraInitializedAndValid = camera == null || !camera.value.isInitialized;
    if (isCameraInitializedAndValid) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(camera),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final text = await controller.captureAndRecognize();
                  setState(() {
                    result = text;
                  });
                },
                child: const Text("Capturar"),
              ),
            ),
          ),
          if (result != null)
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black54,
                child: Text(
                  result!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
        ],
      ),
    );
  }
}