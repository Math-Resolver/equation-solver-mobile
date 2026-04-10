import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/widgets/equation_solver_calculator_keyboard.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/widgets/grid.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/widgets/tabs.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/widgets/toolbar.dart';
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
  final List<TextEditingValue> _undoStack = [];

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.equation ?? "");
  }

  void _saveStateForUndo() {
    _undoStack.add(controller.value);
  }

  void _undoAction() {
    if (_undoStack.isEmpty) return;
    controller.value = _undoStack.removeLast();
  }

  void _moveCursorLeft() {
    final selection = controller.selection;
    final textLength = controller.text.length;
    final current = selection.isCollapsed ? selection.start : selection.start;
    final newOffset = current > 0 ? current - 1 : 0;
    controller.selection = TextSelection.collapsed(offset: newOffset.clamp(0, textLength));
  }

  void _moveCursorRight() {
    final selection = controller.selection;
    final textLength = controller.text.length;
    final current = selection.isCollapsed ? selection.start : selection.end;
    final newOffset = current < textLength ? current + 1 : textLength;
    controller.selection = TextSelection.collapsed(offset: newOffset.clamp(0, textLength));
  }

  void _clearAll() {
    _saveStateForUndo();
    controller.value = const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
  }

  void _backspace() {
    final selection = controller.selection;
    final text = controller.text;
    final textLength = text.length;
    final start = selection.start.clamp(0, textLength);
    final end = selection.end.clamp(0, textLength);

    if (start == end) {
      if (start == 0) return;
      _saveStateForUndo();
      final newText = text.replaceRange(start - 1, start, '');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start - 1),
      );
      return;
    }

    _saveStateForUndo();
    final newText = text.replaceRange(start, end, '');
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F5),
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

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      CalculatorToolbar(
                        onUndo: _undoAction,
                        onMoveLeft: _moveCursorLeft,
                        onMoveRight: _moveCursorRight,
                        onClear: _clearAll,
                        onBackspace: _backspace,
                      ),
                      const SizedBox(height: 8),
                      const CalculatorCategoryTabs(),
                      const SizedBox(height: 12),

                      Container(height: 1, color: Colors.grey.shade300),

                      Expanded(child: CalculatorGrid(controller: controller)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
