import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_http_client.dart';

void main() {
  group('EquationSolverRepositoryImpl API', () {
    test(
      'solveEquation posts expression and parses result with steps',
      () async {
        final httpClient = FakeHttpClient(
          handler: (_) async => {
            'result': 'x = 5',
            'steps': [
              {
                'rule': 'subtrair 5 dos dois lados',
                'before': '2x + 5 = 15',
                'after': '2x = 10',
              },
              {
                'rule': 'dividir por 2',
                'before': '2x = 10',
                'after': 'x = 5',
              },
            ],
          },
        );

        final repository = EquationSolverRepositoryImpl(httpClient: httpClient);

        final result = await repository.solveEquation(
          equation: '2*x + 5 = 15',
          showSteps: true,
        );

        final request = httpClient.requests.single;
        expect(request.path, '/v1/equation/solve');
        expect(request.method, 'POST');
        expect(request.data, {'equation': '2*x + 5 = 15', 'showSteps': true});
        expect(result.result, 'x = 5');
        expect(result.steps, hasLength(2));
        expect(result.steps.first.rule, 'subtrair 5 dos dois lados');
      },
    );
  });
}
