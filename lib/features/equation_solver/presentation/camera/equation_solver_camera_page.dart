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
  State<EquationSolverCameraPage> createState() => _EquationSolverCameraPageState();
}

class _EquationSolverCameraPageState extends State<EquationSolverCameraPage> {
  late final controller = widget.controller;

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
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          _buildCameraPreview(camera),
          _buildFocusRectangle(),
          _buildInstructionText(),
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(CameraController camera) {
    final textureId = camera.textureId;
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: camera.value.previewSize!.height,
          height: camera.value.previewSize!.width,
          child: textureId != null ? Texture(textureId: textureId) : const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildFocusRectangle() {
    return Positioned(
      top: 225,
      left: 20,
      right: 20,
      child: SizedBox(
        width: 350,
        height: 110,
        child: Stack(
          children: [
            equationSolverFocusCorner(top: true, left: true),
            equationSolverFocusCorner(top: true, left: false),
            equationSolverFocusCorner(top: false, left: true),
            equationSolverFocusCorner(top: false, left: false),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionText() {
    return const Positioned(
      bottom: 180,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          'Fotografa um problema de matemática',
          style: TextStyle(color: Colors.white, backgroundColor: Colors.black54, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCalculatorButton(),
          const SizedBox(width: 32),
          _buildCaptureButton(),
          const SizedBox(width: 20),
          _buildFlashAndGalleryIcons(),
          const SizedBox(width: 32),
          _buildChatButton(),
        ],
      ),
    );
  }

  Widget _buildCalculatorButton() {
    return IconButton(
      icon: const Icon(Icons.calculate, color: Colors.white),
      onPressed: () => _navigateTo(const EquationSolverCalculatorPage()),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _handleCapture,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red, width: 4),
        ),
        child: const Center(
          child: CircleAvatar(radius: 25, backgroundColor: Colors.red),
        ),
      ),
    );
  }

  Widget _buildFlashAndGalleryIcons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.flash_on, color: Colors.white),
        SizedBox(width: 20),
        Icon(Icons.photo_library, color: Colors.white),
      ],
    );
  }

  Widget _buildChatButton() {
    return IconButton(
      icon: const Icon(Icons.question_answer_outlined, color: Colors.white),
      onPressed: () => _navigateTo(const ChatAssistantChatPage(equation: '')),
    );
  }

  Future<void> _handleCapture() async {
    final text = await controller.captureAndRecognize();
    if (mounted && text != null && text.isNotEmpty) {
      _navigateTo(EquationSolverCalculatorPage(initialExpression: text));
    }
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}