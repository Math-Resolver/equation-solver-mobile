import 'package:equation_solver_mobile/dependencies.dart';
import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/core/localization/app_text_key.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/equation_solver_camera_controller.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/splash/equation_solver_splash_page.dart';
import 'package:flutter/material.dart';

final dependencies = AppDependencies.instance;
final cameraController = EquationSolverCameraController(
  repository: dependencies.equationRepository,
);
final appLocaleController = dependencies.localeController;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appLocaleController.loadSavedLanguage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLocalizationScope(
      controller: appLocaleController,
      child: AnimatedBuilder(
        animation: appLocaleController,
        builder: (_, __) => MaterialApp(
          title: appLocaleController.text(AppTextKey.calculatorTitle),
          locale: appLocaleController.locale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: EquationSolverSplashPage(controller: cameraController),
        ),
      ),
    );
  }
}
