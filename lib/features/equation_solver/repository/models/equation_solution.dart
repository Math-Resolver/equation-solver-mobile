class EquationSolution {
  const EquationSolution({required this.result, required this.steps});

  final String result;
  final List<EquationSolveStep> steps;

  factory EquationSolution.fromJson(Map<String, dynamic> json) {
    final jsonSteps = (json['steps'] as List<dynamic>? ?? const []);
    return EquationSolution(
      result: (json['result'] ?? '').toString(),
      steps: jsonSteps
          .whereType<Map<String, dynamic>>()
          .map(EquationSolveStep.fromJson)
          .toList(growable: false),
    );
  }
}

class EquationSolveStep {
  const EquationSolveStep({
    required this.rule,
    required this.before,
    required this.after,
  });

  final String rule;
  final String before;
  final String after;

  factory EquationSolveStep.fromJson(Map<String, dynamic> json) {
    return EquationSolveStep(
      rule: (json['rule'] ?? '').toString(),
      before: (json['before'] ?? '').toString(),
      after: (json['after'] ?? '').toString(),
    );
  }
}
