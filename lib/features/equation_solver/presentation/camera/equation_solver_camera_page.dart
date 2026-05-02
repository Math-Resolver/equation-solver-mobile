import 'package:camera/camera.dart';
import 'package:equation_solver_mobile/features/chat_assistant/presentation/chat/chat_assistant_chat_page.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/equation_solver_calculator_page.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/equation_solver_camera_controller.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/widgets/equation_solver_camera_preview.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/widgets/equation_solver_capture_button.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/widgets/equation_solver_flash_gallery_row.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/widgets/equation_solver_focus_rectangle.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/widgets/equation_solver_instruction_text.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/widgets/equation_solver_menu_button.dart';
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
  bool _flashEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await controller.initCamera();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = controller.cameraController;
    if (camera == null || !camera.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      drawer: Drawer(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          color: Colors.white,
        ),
      ),
      body: Builder(
        builder: (context) => Stack(
          children: [
            EquationSolverCameraPreview(camera: camera),
            const EquationSolverFocusRectangle(),
            const EquationSolverInstructionText(),
            _buildControlButtons(),
            EquationSolverMenuButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 90, child: _buildCalculatorButton()),
              const SizedBox(width: 20),
              EquationSolverCaptureButton(onTap: _handleCapture),
              const SizedBox(width: 20),
              SizedBox(width: 90, child: _buildChatButton()),
            ],
          ),
          const SizedBox(height: 16),
          EquationSolverFlashGalleryRow(
            flashEnabled: _flashEnabled,
            onFlashToggle: _toggleFlash,
            onGalleryPick: _handleGalleryPick,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.calculate, color: Colors.white),
          onPressed: () => _navigateTo(const EquationSolverCalculatorPage()),
        ),
        const Text(
          'Calculadora',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildChatButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.question_answer_outlined, color: Colors.white),
          onPressed: () =>
              _navigateTo(const ChatAssistantChatPage(equation: '')),
        ),
        const Text(
          'Killbot',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _toggleFlash() {
    setState(() => _flashEnabled = !_flashEnabled);
    controller.cameraController?.setFlashMode(
      _flashEnabled ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> _handleGalleryPick() async {
    final text = await controller.pickFromGalleryAndRecognize();
    var textIsNotNullOrEmpty = mounted && text != null && text.isNotEmpty;
    if (textIsNotNullOrEmpty) {
      _navigateTo(EquationSolverCalculatorPage(initialExpression: text));
    }
  }

  Future<void> _handleCapture() async {
    final viewportSize = MediaQuery.sizeOf(context);
    final text = await controller.captureAndRecognize(
      viewportSize: viewportSize,
      focusRect: EquationSolverFocusRectangle.rectFor(viewportSize),
    );
    var textIsNotNullOrEmpty = mounted && text != null && text.isNotEmpty;
    if (textIsNotNullOrEmpty) {
      _navigateTo(EquationSolverCalculatorPage(initialExpression: text));
    }
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
