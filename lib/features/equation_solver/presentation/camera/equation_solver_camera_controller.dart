import 'package:camera/camera.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_interface.dart';

class EquationSolverCameraController {
  EquationSolverCameraController({required IEquationSolverRepositoryInterface repository}) 
    : _repository = repository;

  final IEquationSolverRepositoryInterface _repository;
  CameraController? cameraController;

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back);
    cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await cameraController!.initialize();
  }

  Future<String?> captureAndRecognize() async {
    final equationPictureFile = await cameraController!.takePicture();
    final text = await _repository.getRecognizedText(equationPictureFile.path);
    return text;
  }

  void dispose() {
    cameraController?.dispose();
  }
}