import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/widgets/equation_solver_calculator_keyboard.dart';
import 'package:flutter/material.dart';

class EquationSolvercalculatorPage extends StatefulWidget {
  final String? equation;

  const EquationSolvercalculatorPage({super.key, required this.equation});

  @override
  State<EquationSolvercalculatorPage> createState() =>
      _EquationSolvercalculatorPageState();
}

class _EquationSolvercalculatorPageState
    extends State<EquationSolvercalculatorPage> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.equation ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Calculadora",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Fechar",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 120,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: "Digite um problema matemático...",
                    border: UnderlineInputBorder(),
                  ),
                ),
              ),
            ),

            const Spacer(),

            EquationSolverCalculatorKeyboard(controller: controller),
          ],
        ),
      ),
    );
  }
}
