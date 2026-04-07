import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_interface.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class EquationSolverRepositoryImpl implements IEquationSolverRepositoryInterface {
  final TextRecognizer _recognizer = TextRecognizer();

  @override
  Future<String> getRecognizedText(String path) async {
    final image = InputImage.fromFilePath(path);
    final recognizedImageText = await _recognizer.processImage(image);
    return recognizedImageText.text;
  }
}
