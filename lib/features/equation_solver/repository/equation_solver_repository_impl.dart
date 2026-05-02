import 'package:equation_solver_mobile/core/http/http_client_interface.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'equation_solver_repository_interface.dart';
import 'models/equation_solution.dart';

class EquationSolverRepositoryImpl
    implements IEquationSolverRepositoryInterface {
  EquationSolverRepositoryImpl({
    required IHttpClientInterface httpClient,
    TextRecognizer? recognizer,
  })  : _httpClient = httpClient,
        _recognizer = recognizer ?? TextRecognizer();

  final IHttpClientInterface _httpClient;
  final TextRecognizer _recognizer;

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

  @override
  Future<EquationSolution> solveEquation({
    required String equation,
    bool showSteps = true,
  }) async {
    final data = await _httpClient.post(
      '/v1/equation/solve',
      data: {'equation': equation, 'showSteps': showSteps},
    );
    return EquationSolution.fromJson(data);
  }
}
