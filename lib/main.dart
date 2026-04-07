import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/equation_solver_camera_controller.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/equation_solver_camera_page.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_impl.dart';
import 'package:flutter/material.dart';

final repository = EquationSolverRepositoryImpl();

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
      home: EquationSolverCameraPage(
        controller: EquationSolverCameraController(
          repository: repository
        ),
      )
    );
  }
}