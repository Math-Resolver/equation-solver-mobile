import 'models/equation_solution.dart';

abstract class IEquationSolverRepositoryInterface {
  Future<String> getRecognizedText(String path);

  Future<EquationSolution> solveEquation({
    required String equation,
    bool showSteps = true,
  });
}
