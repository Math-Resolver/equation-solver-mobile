import 'package:equation_solver_mobile/dependencies.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/equation_solver_camera_controller.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/splash/equation_solver_splash_page.dart';
import 'package:flutter/material.dart';

final dependencies = AppDependencies.instance;
final cameraController = EquationSolverCameraController(
  repository: dependencies.equationRepository,
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Equation Solver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: EquationSolverSplashPage(controller: cameraController),
    );
  }
}
