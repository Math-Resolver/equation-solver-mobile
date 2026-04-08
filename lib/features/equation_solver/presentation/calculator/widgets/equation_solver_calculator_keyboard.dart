import 'package:equation_solver_mobile/drawables/app_colors.dart';
import 'package:flutter/material.dart';

class EquationSolverCalculatorKeyboard extends StatelessWidget {
  final TextEditingController controller;

  const EquationSolverCalculatorKeyboard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [_buildTopBar(), _buildFunctionBar(), _buildKeyboardGrid()],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: const [
          Text("abc"),
          Spacer(),
          Icon(Icons.undo, size: 18),
          SizedBox(width: 10),
          Icon(Icons.arrow_back, size: 18),
          SizedBox(width: 10),
          Icon(Icons.arrow_forward, size: 18),
          SizedBox(width: 10),
          Icon(Icons.keyboard_return, size: 18),
          SizedBox(width: 10),
          Icon(Icons.backspace, size: 18),
        ],
      ),
    );
  }

  Widget _buildFunctionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _chip("+ − × ÷", selected: true),
          _chip("f(x) e log ln"),
          _chip("sin cos tan cot"),
          _chip("lim dx Σ ∫ ∞"),
        ],
      ),
    );
  }

  Widget _chip(String text, {bool selected = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.selected : AppColors.unselected,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(color: selected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildKeyboardGrid() {
    final buttons = [
      "()",
      "+",
      "÷",
      "7",
      "8",
      "9",
      "1/",
      "√",
      "x",
      "4",
      "5",
      "6",
      "²",
      ">",
      "-",
      "1",
      "2",
      "3",
      "π",
      "%",
      "+",
      "0",
      ",",
      "=",
    ];

    return Container(
      color: Colors.black,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: buttons.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final text = buttons[index];

          return GestureDetector(
            onTap: () {
              final selection = controller.selection;
              int startSelection = selection.start;
              int endSelection = selection.end;
              if (startSelection < 0 || endSelection < 0) {
                startSelection = controller.text.length;
                endSelection = controller.text.length;
              }
              final newText = controller.text.replaceRange(
                startSelection,
                endSelection,
                text,
              );
              controller.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(
                  offset: selection.start + text.length,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: getButtonColor(text)
              ),
              child: Center(
                child: Text(text, style: const TextStyle(fontSize: 30 , fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }

  Color getButtonColor(String text) {
    const numbers = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      ",",
      "=",
    ];

    if (numbers.contains(text)) {
      return AppColors.numbers;
    }

    return AppColors.defaultNumbers;
  }
}
