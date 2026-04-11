import 'package:camera/camera.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_interface.dart';
import 'package:image_picker/image_picker.dart';

class EquationSolverCameraController {
  EquationSolverCameraController({required IEquationSolverRepositoryInterface repository})
      : _repository = repository;

  final IEquationSolverRepositoryInterface _repository;
  CameraController? cameraController;

  Future<void> initCamera() async {
    final backCamera = await _getBackCamera();
    cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await cameraController!.initialize();
  }

  Future<CameraDescription> _getBackCamera() async {
    final cameras = await availableCameras();
    return cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
  }

  Future<String?> captureAndRecognize() async {
    if (cameraController == null) return null;
    try {
      final picture = await cameraController!.takePicture();
      return await _repository.getRecognizedText(picture.path);
    } catch (_) {
      return null;
    }
  }

  Future<String?> pickFromGalleryAndRecognize() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;
      return await _repository.getRecognizedText(image.path);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    cameraController?.dispose();
  }
}