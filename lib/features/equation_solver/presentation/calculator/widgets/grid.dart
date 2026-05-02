import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/widgets/button.dart';
import 'package:flutter/material.dart';

class CalculatorGrid extends StatelessWidget {
  final TextEditingController controller;

  const CalculatorGrid({super.key, required this.controller});

  static const placeholder = '□';

  static const _placeholderPatterns = {
    '()': _PlaceholderPattern('($placeholder)', 1, 1),
    '1/': _PlaceholderPattern('1/$placeholder', 2, 1),
    '√': _PlaceholderPattern('√$placeholder', 1, 1),
    '²': _PlaceholderPattern('²$placeholder', 1, 1),
  };

  void insertText(String text) {
    final selection = controller.selection;
    final textLength = controller.text.length;

    int start = selection.start.clamp(0, textLength);
    int end = selection.end.clamp(0, textLength);

    if (end < start) {
      final temp = start;
      start = end;
      end = temp;
    }

    final pattern = _placeholderPatterns[text];
    final insertedText = pattern?.text ?? text;

    final newText = controller.text.replaceRange(start, end, insertedText);
    final selectionBase = start + (pattern?.selectionStartOffset ?? insertedText.length);
    final selectionEnd = selectionBase + (pattern?.selectionLength ?? 0);

    controller.value = TextEditingValue(
      text: newText,
      selection: pattern != null
          ? TextSelection(baseOffset: selectionBase, extentOffset: selectionEnd)
          : TextSelection.collapsed(offset: selectionBase),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
      children: [
        TableRow(children: [
          _btn("()", ButtonType.function),
          _btn("+", ButtonType.operator),
          _btn("÷", ButtonType.operator),
          _btn("7", ButtonType.number),
          _btn("8", ButtonType.number),
          _btn("9", ButtonType.number),
        ]),
        TableRow(children: [
          _btn("1/", ButtonType.function),
          _btn("√", ButtonType.function),
          _btn("×", ButtonType.operator),
          _btn("4", ButtonType.number),
          _btn("5", ButtonType.number),
          _btn("6", ButtonType.number),
        ]),
        TableRow(children: [
          _btn("²", ButtonType.function),
          _btn(">", ButtonType.operator),
          _btn("-", ButtonType.operator),
          _btn("1", ButtonType.number),
          _btn("2", ButtonType.number),
          _btn("3", ButtonType.number),
        ]),
        TableRow(children: [
          _btn("π", ButtonType.function),
          _btn("%", ButtonType.operator),
          _btn("+", ButtonType.operator),
          _btn("0", ButtonType.number),
          _btn(",", ButtonType.number),
          _btn("=", ButtonType.number),
        ]),
      ],
    );
  }

  Widget _btn(String text, ButtonType type) {
    return CalculatorButton(
      label: text,
      type: type,
      onTap: () => insertText(text),
    );
  }
}

class _PlaceholderPattern {
  final String text;
  final int selectionStartOffset;
  final int selectionLength;

  const _PlaceholderPattern(
    this.text,
    this.selectionStartOffset,
    this.selectionLength,
  );
}