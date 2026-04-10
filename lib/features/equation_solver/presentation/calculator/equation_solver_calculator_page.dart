import 'package:flutter/material.dart';
import 'equation_solver_calculator_controller.dart';

class EquationSolverCalculatorPage extends StatefulWidget {
  final String? initialExpression;

  const EquationSolverCalculatorPage({this.initialExpression, super.key});

  @override
  State<EquationSolverCalculatorPage> createState() => _EquationSolverCalculatorPageState();
}

class _EquationSolverCalculatorPageState extends State<EquationSolverCalculatorPage> {
  late EquationSolverCalculatorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EquationSolverCalculatorController();
    _loadInitialExpression();
  }

  void _loadInitialExpression() {
    final expression = widget.initialExpression;
    final expressionIsNotNullOrEmpty = expression != null && expression.isNotEmpty;
    if (expressionIsNotNullOrEmpty) {
      _controller.loadExpression(expression);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Column(
              children: [
                _buildExpressionDisplay(),
                _buildControlButtons(),
                Expanded(child: _buildKeyboard()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Center(
            child: Text(
              'Calculadora',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/camera'),
              child: Text(
                'Fechar',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpressionDisplay() {
    return Container(
      key: const Key('expression_display'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        _controller.expression.isEmpty ? '' : _controller.expression,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildIconButton('undo_button', Icons.undo, () => _setState(() => _controller.undo())),
            _buildIconButton('cursor_left_button', Icons.arrow_back, () => _setState(() => _controller.moveCursorLeft())),
            _buildIconButton('cursor_right_button', Icons.arrow_forward, () => _setState(() => _controller.moveCursorRight())),
            _buildIconButton('delete_button', Icons.backspace, () => _setState(() => _controller.deleteCharacter())),
            _buildIconButton('clear_button', Icons.clear, () => _setState(() => _controller.clear())),
            _buildIconButton('input_set_toggle', Icons.language, () => _setState(() => _controller.toggleKeyboard())),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(String key, IconData icon, VoidCallback onPressed) {
    return IconButton(
      key: Key(key),
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }

  Widget _buildKeyboard() {
    final keyboardType = _controller.activeKeyboardType;
    final keyboardKey = 'keyboard_${keyboardType}_mode';

    return Container(
      key: Key(keyboardKey),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildSymbolGrid(),
            if (_controller.activeKeyboard.structures.isNotEmpty)
              _buildStructureGrid(),
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
          onPressed: () => _setState(() => _controller.insertSymbol(symbols[index])),
          child: Text(
            symbols[index],
            key: const Key('symbol_button'),
          ),
        ),
      ),
    );
  }

  Widget _buildStructureGrid() {
    final structures = _controller.activeKeyboard.structures;

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
          onPressed: () => _setState(() => _controller.insertStructure(structures[index])),
          child: Text(
            structures[index],
            key: const Key('structure_button'),
          ),
        ),
      ),
    );
  }

  void _setState(VoidCallback fn) {
    setState(fn);
  }
}
