import 'dart:async';

import 'package:equation_solver_mobile/drawables/app_colors.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/equation_solver_camera_controller.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/camera/equation_solver_camera_page.dart';
import 'package:flutter/material.dart';

class EquationSolverSplashPage extends StatefulWidget {
  const EquationSolverSplashPage({required this.controller, super.key});

  final EquationSolverCameraController controller;

  @override
  State<EquationSolverSplashPage> createState() =>
      _EquationSolverSplashPageState();
}

class _EquationSolverSplashPageState extends State<EquationSolverSplashPage> {
  static const splashDuration = Duration(milliseconds: 1500);
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(splashDuration, _goToCameraPage);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _goToCameraPage() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EquationSolverCameraPage(controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/killmath_logo.png',
              key: const Key('killmath_splash_logo'),
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 18),
            const Text(
              'killmath',
              style: TextStyle(
                color: AppColors.splashText,
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
