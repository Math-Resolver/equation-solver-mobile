import 'package:flutter/material.dart';

class EquationSolverCalculatorKeyboard extends StatelessWidget {
  final TextEditingController controller;

  const EquationSolverCalculatorKeyboard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ["(", ")", "+", "÷"],
      ["1/x", "√", "x", "7"],
      ["8", "9", "4", "5"],
      ["6", "1", "2", "3"],
      ["π", "%", "0", "="],
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: buttons.map((row) {
          return Row(
            children: row.map((text) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ElevatedButton(
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
                        )
                      );
                    },
                    child: Text(text),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
