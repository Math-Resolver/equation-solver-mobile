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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        Text("abc"),
        Icon(Icons.undo),
        Icon(Icons.arrow_back),
        Icon(Icons.arrow_forward),
        Icon(Icons.keyboard_return),
        Icon(Icons.backspace),
      ],
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
          color: selected ? Colors.blue : Colors.grey[200],
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
      ["(", ")", "+", "÷"],
      ["1/x", "√", "x", "7"],
      ["8", "9", "4", "5"],
      ["6", "1", "2", "3"],
      ["π", "%", "0", "="],
    ];

    return Column(
      children: buttons.map((row) {
        return Row(
          children: row.map((text) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getButtonColor(text),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: () {
                    final selection = controller.selection;
                    final newText = controller.text.replaceRange(
                      selection.start,
                      selection.end,
                      text,
                    );

                    controller.value = TextEditingValue(
                      text: newText,
                      selection: TextSelection.collapsed(
                        offset: selection.start + text.length,
                      ),
                    );
                  },
                  child: Text(text),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Color getButtonColor(String text) {
    const numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];

    if (numbers.contains(text)) return Colors.blue.shade200;
    return Colors.grey.shade300;
  }
}
