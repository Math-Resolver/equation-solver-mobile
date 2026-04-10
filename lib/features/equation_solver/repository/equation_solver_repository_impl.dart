import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'equation_solver_repository_interface.dart';

class EquationSolverRepositoryImpl implements IEquationSolverRepositoryInterface {
  final TextRecognizer _recognizer = TextRecognizer();

  @override
  Future<String> getRecognizedText(String path) async {
    try {
      final image = InputImage.fromFilePath(path);
      final result = await _recognizer.processImage(image);
      return result.text.trim();
    } catch (e) {
      return '';
    }
  }
}
