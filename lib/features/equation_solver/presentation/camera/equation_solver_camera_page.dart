import 'package:camera/camera.dart';
import 'package:equation_solver_mobile/features/chat_assistant/presentation/chat/chat_assistant_chat_page.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/equation_solver_calculator_page.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/equation_solver_camera_controller.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/widgets/equation_solver_focus_corner.dart';
import 'package:flutter/material.dart';

class EquationSolverCameraPage extends StatefulWidget {
  const EquationSolverCameraPage({required this.controller, super.key});

  final EquationSolverCameraController controller;

  @override
  State<EquationSolverCameraPage> createState() =>
      _EquationSolverCameraPageState();
}

class _EquationSolverCameraPageState extends State<EquationSolverCameraPage> {
  late final controller = widget.controller;
  String? result;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller.initCamera().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final camera = controller.cameraController;
    final isCameraNotReady = camera == null || !camera.value.isInitialized;
    if (isCameraNotReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(camera),

          const Positioned(
            top: 50,
            left: 20,
            child: Icon(Icons.menu, color: Colors.white, size: 30),
          ),

          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
              ),
              child: Stack(
                children: [
                  equationSolverFocusCorner(top: true, left: true),
                  equationSolverFocusCorner(top: true, left: false),
                  equationSolverFocusCorner(top: false, left: true),
                  equationSolverFocusCorner(top: false, left: false),
                ],
              ),
            ),
          ),

          const Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Fotografa um problema de matemática",
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EquationSolvercalculatorPage(
                              equation: result ?? "",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calculate),
                    ),
                    const Text(
                      "Calculadora",
                      style: TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatAssistantChatPage(
                              equation: ""
                            )
                          )
                        );
                      },
                      icon: const Icon(Icons.question_answer_outlined),
                    )
                  ],
                ),

                GestureDetector(
                  onTap: () async {
                    setState(() => isProcessing = true);
                    final text = await controller.captureAndRecognize();
                    if (!mounted) return;
                    setState(() => isProcessing = false);
                    if (text != null && text.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EquationSolvercalculatorPage(equation: text),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ),

                const Icon(Icons.flash_on, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}