import 'package:equation_solver_mobile/drawables/app_colors.dart';
import 'package:flutter/material.dart';
import 'equation_solver_calculator_controller.dart';
import 'widgets/block_math_input.dart';

class EquationSolverCalculatorPage extends StatefulWidget {
  final String? initialExpression;

  const EquationSolverCalculatorPage({this.initialExpression, super.key});

  @override
  State<EquationSolverCalculatorPage> createState() =>
      _EquationSolverCalculatorPageState();
}

class _EquationSolverCalculatorPageState
    extends State<EquationSolverCalculatorPage> {
  late EquationSolverCalculatorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EquationSolverCalculatorController();
    _loadInitialExpression();
  }

  void _loadInitialExpression() {
    final expression = widget.initialExpression;
    final expressionIsNotNullOrEmpty =
        expression != null && expression.isNotEmpty;
    if (expressionIsNotNullOrEmpty) {
      _controller.loadExpression(expression);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Column(
                children: [
                  Expanded(flex: 6, child: _buildExpressionDisplay()),
                  _buildControlButtons(),
                  _buildTabRow(),
                  Expanded(flex: 4, child: _buildKeyboard()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Center(
            child: const Text(
              'Calculadora',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).canPop()
                  ? Navigator.of(context).pop()
                  : Navigator.of(context).pushReplacementNamed('/camera'),
              child: Text(
                'Fechar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.selected,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpressionDisplay() {
    return BlockMathInput(
      state: _controller.editorState,
      onSelectionChanged: (rowNodeId, offset) =>
          _setState(() => _controller.focusRow(rowNodeId, offset)),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          key: const Key('control_buttons_scroll'),
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  key: const Key('input_set_toggle'),
                  onPressed: () =>
                      _setState(() => _controller.switchKeyboard('abc')),
                  child: const Text(
                    'abc',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                _buildIconButton(
                  'undo_button',
                  Icons.history,
                  () => _setState(() => _controller.undo()),
                ),
                _buildIconButton(
                  'cursor_left_button',
                  Icons.arrow_back,
                  () => _setState(() => _controller.moveCursorLeft()),
                ),
                _buildIconButton(
                  'cursor_right_button',
                  Icons.arrow_forward,
                  () => _setState(() => _controller.moveCursorRight()),
                ),
                _buildIconButton('submit_button', Icons.keyboard_return, () {}),
                _buildIconButton(
                  'delete_button',
                  Icons.backspace_outlined,
                  () => _setState(() => _controller.deleteCharacter()),
                ),
                Visibility(
                  visible: false,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  maintainInteractivity: true,
                  child: _buildIconButton(
                    'clear_button',
                    Icons.clear,
                    () => _setState(() => _controller.clear()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(String key, IconData icon, VoidCallback onPressed) {
    return IconButton(key: Key(key), icon: Icon(icon), onPressed: onPressed);
  }

  Widget _buildTabRow() {
    const tabIds = ['basic', 'functions', 'trig', 'calculus'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(children: tabIds.map(_buildTab).toList()),
    );
  }

  Widget _buildTab(String keyboardId) {
    final isSelected = _controller.activeKeyboardType == keyboardId;
    final label = _controller.getKeyboard(keyboardId).label;
    return GestureDetector(
      key: Key('tab_$keyboardId'),
      onTap: () => _setState(() => _controller.switchKeyboard(keyboardId)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selected : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.selected : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    final keyboardType = _controller.activeKeyboardType;
    final keyboardKey = 'keyboard_${keyboardType}_mode';
    final keyboard = _controller.activeKeyboard;

    if (keyboard.orderedLayout != null) {
      return Container(
        key: Key(keyboardKey),
        color: AppColors.keyboardOperator.withValues(alpha: 0.3),
        child: _buildOrderedGrid(keyboard.orderedLayout!, keyboard),
      );
    }

    return Container(
      key: Key(keyboardKey),
      color: AppColors.keyboardOperator.withValues(alpha: 0.3),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildSymbolGrid(),
            if (keyboard.structures.isNotEmpty) _buildStructureGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSymbolGrid() {
    final symbols = _controller.activeKeyboard.symbols.toList();
    return Container(
      key: const Key('active_keyboard'),
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: symbols.length,
        itemBuilder: (context, index) => ElevatedButton(
          key: Key('symbol_button_${symbols[index]}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.keyboardOperator,
            foregroundColor: Colors.black87,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () =>
              _setState(() => _controller.insertSymbol(symbols[index])),
          child: Text(symbols[index], key: const Key('symbol_button')),
        ),
      ),
    );
  }

  Widget _buildOrderedGrid(List<String> orderedLayout, KeyboardType keyboard) {
    const spacing = 4.0;
    const padding = 8.0;
    const cols = 6;
    final rows = (orderedLayout.length / cols).ceil();

    return Container(
      key: const Key('active_keyboard'),
      padding: const EdgeInsets.all(padding),
      child: Column(
        children: [
          for (var r = 0; r < rows; r++) ...[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var c = 0; c < cols; c++) ...[
                    Expanded(
                      child: (r * cols + c) < orderedLayout.length
                          ? _buildOrderedButton(
                              label: orderedLayout[r * cols + c],
                              keyboard: keyboard,
                              col: c,
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (c < cols - 1) const SizedBox(width: spacing),
                  ],
                ],
              ),
            ),
            if (r < rows - 1) const SizedBox(height: spacing),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderedButton({
    required String label,
    required KeyboardType keyboard,
    required int col,
  }) {
    final isStructure = keyboard.structures.any((item) => item.label == label);
    final usesNumericStyling = keyboard.id == 'basic';
    final isRightColumn = usesNumericStyling && col >= 3;
    final isDigit = int.tryParse(label) != null;
    final bgColor = isRightColumn
        ? AppColors.keyboardNumbers
        : AppColors.keyboardOperator;
    final textColor = isRightColumn ? Colors.white : Colors.black87;
    final widgetKey = isStructure
        ? Key('structure_button_$label')
        : Key('symbol_button_$label');
    final childKey = isStructure
        ? const Key('structure_button')
        : const Key('symbol_button');
    final onTap = isStructure
        ? () => _setState(() => _controller.insertStructure(label))
        : () => _setState(() => _controller.insertSymbol(label));

    return ElevatedButton(
      key: widgetKey,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(
        label,
        key: childKey,
        style: TextStyle(
          fontSize: isDigit ? 22 : 16,
          fontWeight: isDigit ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStructureGrid() {
    final structures = _controller.activeKeyboard.structures
        .map((item) => item.label)
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: structures.length,
        itemBuilder: (context, index) => ElevatedButton(
          key: Key('structure_button_${structures[index]}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.keyboardOperator,
            foregroundColor: Colors.black87,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () =>
              _setState(() => _controller.insertStructure(structures[index])),
          child: Text(structures[index], key: const Key('structure_button')),
        ),
      ),
    );
  }

  void _setState(VoidCallback fn) {
    setState(fn);
  }
}
