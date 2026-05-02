import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/equation_solver_camera_controller.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/equation_solver_camera_page.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/splash/equation_solver_splash_page.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeEquationSolverRepository implements IEquationSolverRepositoryInterface {
  @override
  Future<String> getRecognizedText(String path) async {
    return '';
  }
}

class StubCameraController extends EquationSolverCameraController {
  StubCameraController({required super.repository});

  @override
  Future<void> initCamera() async {}
}

void main() {
  group('EquationSolverSplashPage', () {
    late StubCameraController controller;

    setUp(() {
      controller =
          StubCameraController(repository: FakeEquationSolverRepository());
    });

    testWidgets('renders logo and brand text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: EquationSolverSplashPage(controller: controller)),
      );

      expect(find.byKey(const Key('killmath_splash_logo')), findsOneWidget);
      expect(find.text('killmath'), findsOneWidget);
    });

    testWidgets('navigates to camera page after 1.5 seconds', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: EquationSolverSplashPage(controller: controller)),
      );

      expect(find.byType(EquationSolverCameraPage), findsNothing);

      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump();

      expect(find.byType(EquationSolverCameraPage), findsOneWidget);
    });
  });
}
