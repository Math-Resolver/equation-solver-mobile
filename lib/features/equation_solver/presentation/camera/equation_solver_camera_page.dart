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
            _buildCameraPreview(camera),
            _buildFocusRectangle(),
            _buildInstructionText(),
            _buildControlButtons(),
            _buildMenuButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(CameraController camera) {
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
    return Positioned(
      bottom: 210,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Fotografa um problema de matemática',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
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
              SizedBox(
                width: 90,
                child: _buildCalculatorButton(),
              ),
              const SizedBox(width: 20),
              _buildCaptureButton(),
              const SizedBox(width: 20),
              SizedBox(
                width: 90,
                child: _buildChatButton(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFlashAndGalleryIcons(),
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

  Widget _buildCaptureButton() {
    return GestureDetector(
      key: const Key('capture_button'),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.photo_library, color: Colors.white),
          onPressed: _handleGalleryPick,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 40),
        IconButton(
          icon: Icon(
            Icons.flash_on,
            color: _flashEnabled ? Colors.yellow : Colors.white,
          ),
          onPressed: _toggleFlash,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
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
          onPressed: () => _navigateTo(const ChatAssistantChatPage(equation: '')),
        ),
        const Text(
          'Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return Positioned(
      top: 40,
      left: 10,
      child: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 30),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
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
    final text = await controller.captureAndRecognize();
    var textIsNotNullOrEmpty = mounted && text != null && text.isNotEmpty;
    if (textIsNotNullOrEmpty) {
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