import 'package:equatable/equatable.dart';

class EquationSolverResponse extends Equatable
{
  const EquationSolverResponse({
    this.result,
    this.steps
  });

  final String? result;
  final List<EquationSolverStepsResponse>? steps;

  @override
  List<Object?> get props => [result, steps];
}

class EquationSolverStepsResponse extends Equatable
{
  const EquationSolverStepsResponse({
    this.rule,
    this.before,
    this.after
  });

  final String? rule;
  final String? before;
  final String? after;

  @override
  List<Object?> get props => [rule, before, after];
}