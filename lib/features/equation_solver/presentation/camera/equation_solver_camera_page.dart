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
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: camera.value.previewSize!.height,
                height: camera.value.previewSize!.width,
                child: CameraPreview(camera),
              ),
            ),
          ),
          const Positioned(
            top: 70,
            left: 20,
            child: Icon(Icons.menu, color: Colors.white, size: 40),
          ),

          Positioned(
            top: 225,
            left: 20,
            right: 20,
            child: SizedBox(
              width: 350,
              height: 110,
              child: Stack(
                clipBehavior: Clip.none,
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
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 110,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          icon: const Icon(Icons.calculate, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Calculadora",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 32),

                  SizedBox(
                    width: 100,
                    height: 110,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                              border: Border.all(color: Colors.red, width: 4),
                            ),
                            child: const Center(
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.flash_on, color: Colors.white, fontWeight: FontWeight.bold),
                            SizedBox(width: 20),
                            Icon(Icons.photo_library, color: Colors.white, fontWeight: FontWeight.bold),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 32),

                  SizedBox(
                    width: 100,
                    height: 110,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatAssistantChatPage(equation: ""),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.question_answer_outlined,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Chat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
