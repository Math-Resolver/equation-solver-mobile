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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Calculadora",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Fechar",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: 0),
                          hintText: "Digite um problema matemático..",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          const dotWidth = 2.0;
                          const spacing = 3.0;

                          final count = (width / (dotWidth + spacing)).floor();

                          return Row(
                            children: List.generate(count, (_) {
                              return Padding(
                                padding: const EdgeInsets.only(right: spacing),
                                child: Container(
                                  width: dotWidth,
                                  height: 1,
                                  color: Colors.grey.shade500,
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ],
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
