import 'package:camera/camera.dart';
import 'package:cross_file/cross_file.dart';
import 'package:equation_solver_mobile/features/chat_assistant/presentation/chat/chat_assistant_chat_page.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/equation_solver_calculator_page.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/equation_solver_camera_controller.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/equation_solver_camera_page.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements IEquationSolverRepositoryInterface {}
class MockCameraController extends Mock implements CameraController {}
class MockCameraValue extends Mock implements CameraValue {}

class StubCameraController extends EquationSolverCameraController {
  final Future<String?> Function()? captureCallback;
  final Future<void> Function()? initCallback;

  StubCameraController({
    required IEquationSolverRepositoryInterface repository,
    this.captureCallback,
    this.initCallback,
  }) : super(repository: repository);

  @override
  Future<void> initCamera() async {
    if (initCallback != null) {
      return initCallback!();
    }
  }

  @override
  Future<String?> captureAndRecognize() async {
    if (captureCallback != null) {
      return captureCallback!();
    }
    return null;
  }
}

void main() {
  group('EquationSolverCameraController use cases', () {
    late MockRepository repository;
    late EquationSolverCameraController controller;
    late MockCameraController cameraController;

    setUp(() {
      repository = MockRepository();
      controller = EquationSolverCameraController(repository: repository);
      cameraController = MockCameraController();
      controller.cameraController = cameraController;
    });

    test('captureAndRecognize takes a picture and returns recognized text', () async {
      const picturePath = 'fake_path.jpg';
      final picture = XFile(picturePath);

      when(() => cameraController.takePicture()).thenAnswer((_) async => picture);
      when(() => repository.getRecognizedText(picturePath))
          .thenAnswer((_) async => 'x + 2 = 5');

      final result = await controller.captureAndRecognize();

      expect(result, 'x + 2 = 5');
      verify(() => cameraController.takePicture()).called(1);
      verify(() => repository.getRecognizedText(picturePath)).called(1);
    });

    test('dispose forwards dispose to the underlying camera controller', () {
      when(() => cameraController.dispose()).thenAnswer((_) async {});

      controller.dispose();

      verify(() => cameraController.dispose()).called(1);
    });

    test('initCamera is defined but requires camera plugin mocking', () {
      expect(() => controller.initCamera(), returnsNormally);
    }, skip: true);
  });

  group('EquationSolverCameraPage widget use cases', () {
    late MockRepository repository;
    late StubCameraController controller;
    late MockCameraController cameraController;
    late MockCameraValue cameraValue;

    setUp(() {
      repository = MockRepository();
      cameraController = MockCameraController();
      cameraValue = MockCameraValue();
      when(() => cameraValue.isInitialized).thenReturn(true);
      when(() => cameraValue.previewSize).thenReturn(const Size(640, 480));
    });

    testWidgets('shows loading indicator while camera is initializing', (WidgetTester tester) async {
      controller = StubCameraController(
        repository: repository,
        initCallback: () async {},
      );

      await tester.pumpWidget(
        MaterialApp(home: EquationSolverCameraPage(controller: controller)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('tapping calculator icon navigates to calculator page', (WidgetTester tester) async {
      controller = StubCameraController(
        repository: repository,
        initCallback: () async {},
      );
      controller.cameraController = cameraController;
      when(() => cameraController.value).thenReturn(cameraValue);

      await tester.pumpWidget(
        MaterialApp(home: EquationSolverCameraPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.calculate));
      await tester.pumpAndSettle();

      expect(find.byType(EquationSolvercalculatorPage), findsOneWidget);
    });

    testWidgets('tapping chat icon navigates to chat page', (WidgetTester tester) async {
      controller = StubCameraController(
        repository: repository,
        initCallback: () async {},
      );
      controller.cameraController = cameraController;
      when(() => cameraController.value).thenReturn(cameraValue);

      await tester.pumpWidget(
        MaterialApp(home: EquationSolverCameraPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.question_answer_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(ChatAssistantChatPage), findsOneWidget);
    });

    testWidgets('tapping capture button navigates to calculator when text is returned', (WidgetTester tester) async {
      controller = StubCameraController(
        repository: repository,
        initCallback: () async {},
        captureCallback: () async => 'x + 2 = 5',
      );
      controller.cameraController = cameraController;
      when(() => cameraController.value).thenReturn(cameraValue);

      await tester.pumpWidget(
        MaterialApp(home: EquationSolverCameraPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byType(EquationSolvercalculatorPage), findsOneWidget);
    });

    testWidgets('tapping capture button does not navigate when text is empty', (WidgetTester tester) async {
      controller = StubCameraController(
        repository: repository,
        initCallback: () async {},
        captureCallback: () async => '',
      );
      controller.cameraController = cameraController;
      when(() => cameraController.value).thenReturn(cameraValue);

      await tester.pumpWidget(
        MaterialApp(home: EquationSolverCameraPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byType(EquationSolvercalculatorPage), findsNothing);
    });
  });
}
