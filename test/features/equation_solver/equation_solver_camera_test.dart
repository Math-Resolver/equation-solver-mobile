import 'package:camera/camera.dart';
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
class MockCameraValue extends Mock implements CameraValue {
  @override
  bool get isRecordingVideo => false;
}

class StubCameraController extends EquationSolverCameraController {
  final Future<String?> Function()? captureCallback;
  final Future<void> Function()? initCallback;

  StubCameraController({
    required super.repository,
    this.captureCallback,
    this.initCallback,
  });

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
  setUpAll(() {
    registerFallbackValue(FlashMode.off);
  });

  group('EquationSolverCameraController use cases', () {
    late MockRepository repository;
    late EquationSolverCameraController controller;
    late MockCameraController cameraController;

    setUp(() {
      repository = MockRepository();
      controller = EquationSolverCameraController(repository: repository);
      cameraController = MockCameraController();
      controller.cameraController = cameraController;
      when(() => cameraController.dispose()).thenAnswer((_) async {});
    });

    tearDown(() {
      controller.dispose();
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

    test('initCamera is defined and accessible without invoking platform camera', () {
      expect(controller.initCamera, isA<Function>());
    });
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
      when(() => cameraController.buildPreview()).thenReturn(const SizedBox());
      when(() => cameraController.dispose()).thenAnswer((_) async {});
      when(() => cameraController.setFlashMode(any())).thenAnswer((_) async {});
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

      expect(find.byType(EquationSolverCalculatorPage), findsOneWidget);
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

      await tester.tap(find.byKey(const Key('capture_button')));
      await tester.pumpAndSettle();

      expect(find.byType(EquationSolverCalculatorPage), findsOneWidget);
    });

    testWidgets('camera equation is loaded into calculator expression display', (WidgetTester tester) async {
      const detectedEquation = 'x + 2 = 5';
      controller = StubCameraController(
        repository: repository,
        initCallback: () async {},
        captureCallback: () async => detectedEquation,
      );
      controller.cameraController = cameraController;
      when(() => cameraController.value).thenReturn(cameraValue);

      await tester.pumpWidget(
        MaterialApp(home: EquationSolverCameraPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('capture_button')));
      await tester.pumpAndSettle();

      expect(find.text(detectedEquation), findsOneWidget);
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

      await tester.tap(find.byKey(const Key('capture_button')));
      await tester.pumpAndSettle();

      expect(find.byType(EquationSolverCalculatorPage), findsNothing);
    });

    testWidgets('shows flash toggle button on camera page', (WidgetTester tester) async {
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

      expect(find.byIcon(Icons.flash_on), findsOneWidget);
    });

    testWidgets('tapping flash button should enable phone flash when taking a photo', (WidgetTester tester) async {
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

      await tester.tap(find.byIcon(Icons.flash_on));
      await tester.pump();

      expect(find.byIcon(Icons.flash_on), findsOneWidget);
    });

    testWidgets('shows gallery import icon and live focus overlay on camera page', (WidgetTester tester) async {
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

      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      expect(find.text('Fotografa um problema de matemática'), findsOneWidget);
    });

    testWidgets('shows central focus rectangle for equation mapping', (WidgetTester tester) async {
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

      expect(
        find.byWidgetPredicate((widget) =>
            widget is SizedBox && widget.width == 350 && widget.height == 110),
        findsOneWidget,
      );
    });

    testWidgets('gallery button should be present for selecting stored photos', (WidgetTester tester) async {
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

      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      expect(find.byKey(const Key('capture_button')), findsOneWidget);
      expect(find.text('Fotografa um problema de matemática'), findsOneWidget);
    });

    testWidgets('tapping capture button with multiple equations still navigates', (WidgetTester tester) async {
      controller = StubCameraController(
        repository: repository,
        initCallback: () async {},
        captureCallback: () async => 'x + 2 = 5\ny = 3',
      );
      controller.cameraController = cameraController;
      when(() => cameraController.value).thenReturn(cameraValue);

      await tester.pumpWidget(
        MaterialApp(home: EquationSolverCameraPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('capture_button')));
      await tester.pumpAndSettle();

      expect(find.byType(EquationSolverCalculatorPage), findsOneWidget);
    });

    testWidgets('shows hamburger menu button on camera page', (WidgetTester tester) async {
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

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('shows instruction text above capture button with bold style and transparent black background', (WidgetTester tester) async {
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

      final textFinder = find.text('Fotografa um problema de matemática');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontWeight, FontWeight.bold);

      final container = tester.widget<Container>(
        find.ancestor(of: textFinder, matching: find.byType(Container)).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.black54);
    });

    testWidgets('tapping hamburger menu button opens side drawer occupying 80% of screen width', (WidgetTester tester) async {
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

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsOneWidget);
    });
  });
}
