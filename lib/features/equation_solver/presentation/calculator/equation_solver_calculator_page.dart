import 'dart:async';

import 'package:equation_solver_mobile/dependencies.dart';
import 'package:equation_solver_mobile/core/http/http_exception.dart';
import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/core/localization/app_text_key.dart';
import 'package:equation_solver_mobile/drawables/app_colors.dart';
import 'package:equation_solver_mobile/drawables/app_top_bar_text_styles.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_interface.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/models/equation_solution.dart';
import 'package:flutter/material.dart';
import 'equation_solver_calculator_controller.dart';
import 'widgets/block_math_input.dart';

class EquationSolverCalculatorPage extends StatefulWidget {
  final String? initialExpression;
  final IEquationSolverRepositoryInterface? repository;

  const EquationSolverCalculatorPage({
    this.initialExpression,
    this.repository,
    super.key,
  });

  @override
  State<EquationSolverCalculatorPage> createState() =>
      _EquationSolverCalculatorPageState();
}

class _EquationSolverCalculatorPageState
    extends State<EquationSolverCalculatorPage> {
  static const _solveDebounceDuration = Duration(seconds: 1);

  late EquationSolverCalculatorController _controller;
  Timer? _solveDebounceTimer;

  @override
  void initState() {
    super.initState();
    final repo =
        widget.repository ?? AppDependencies.instance.equationRepository;
    _controller = EquationSolverCalculatorController(repository: repo);
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
  void dispose() {
    _solveDebounceTimer?.cancel();
    super.dispose();
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
    final localeController = AppLocalizationScope.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Center(
            child: Text(
              localeController.text(AppTextKey.calculatorTitle),
              style: AppTopBarTextStyles.title(color: Colors.black),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).canPop()
                  ? Navigator.of(context).pop()
                  : Navigator.of(context).pushReplacementNamed('/camera'),
              child: Text(
                localeController.text(AppTextKey.calculatorClose),
                style: AppTopBarTextStyles.action(color: AppColors.selected),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSolve() async {
    if (_controller.expression.isEmpty) return;
    setState(() {});
    await _controller.solve();
    if (!mounted) return;
    setState(() {});
    if (_controller.solveError != null) {
      final localeController = AppLocalizationScope.of(context);
      final messageKey = _resolveSolveErrorTextKey(_controller.solveError!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localeController.text(messageKey))),
      );
    }
  }

  void _scheduleSolveDebounced() {
    _solveDebounceTimer?.cancel();
    _solveDebounceTimer = Timer(_solveDebounceDuration, () {
      if (!mounted) {
        return;
      }
      _handleSolve();
    });
  }

  void _runExpressionMutation(VoidCallback action) {
    final previousExpression = _controller.expression;
    _setState(action);
    if (_controller.expression != previousExpression) {
      _scheduleSolveDebounced();
    }
  }

  void _noopSubmit() {}

  AppTextKey _resolveSolveErrorTextKey(Object error) {
    if (error is HttpException && error.statusCode == 400) {
      return AppTextKey.calculatorSolveBadRequest;
    }
    return AppTextKey.calculatorSolveError;
  }

  Widget _buildExpressionDisplay() {
    return Column(
      children: [
        Expanded(
          child: BlockMathInput(
            state: _controller.editorState,
            onSelectionChanged: (rowNodeId, offset) =>
                _setState(() => _controller.focusRow(rowNodeId, offset)),
          ),
        ),
        _buildSolveResultPanel(),
      ],
    );
  }

  Widget _buildSolveResultPanel() {
    if (_controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: CircularProgressIndicator(),
      );
    }
    final sol = _controller.solution;
    if (sol == null) return const SizedBox.shrink();
    final hasSteps = sol.steps.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.selected.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.selected.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sol.result,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (hasSteps) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('solve_steps_open_button'),
                onPressed: () => _openSolveStepsModal(sol),
                icon: const Icon(Icons.format_list_numbered),
                label: const Text('Ver passo a passo'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openSolveStepsModal(EquationSolution solution) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.75,
            child: _SolveStepsModal(
              solution: solution,
              onClose: () => Navigator.of(modalContext).pop(),
            ),
          ),
        );
      },
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
                  () => _runExpressionMutation(() => _controller.undo()),
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
                _buildIconButton(
                  'submit_button',
                  Icons.keyboard_return,
                  _noopSubmit,
                ),
                _buildIconButton(
                  'delete_button',
                  Icons.backspace_outlined,
                  () => _runExpressionMutation(
                    () => _controller.deleteCharacter(),
                  ),
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
                    () => _runExpressionMutation(() => _controller.clear()),
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
          onPressed: () => _runExpressionMutation(
            () => _controller.insertSymbol(symbols[index]),
          ),
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
        ? () => _runExpressionMutation(() => _controller.insertStructure(label))
        : () => _runExpressionMutation(() => _controller.insertSymbol(label));

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
          onPressed: () => _runExpressionMutation(
            () => _controller.insertStructure(structures[index]),
          ),
          child: Text(structures[index], key: const Key('structure_button')),
        ),
      ),
    );
  }

  void _setState(VoidCallback fn) {
    setState(fn);
  }
}

class _SolveStepsModal extends StatefulWidget {
  const _SolveStepsModal({required this.solution, required this.onClose});

  final EquationSolution solution;
  final VoidCallback onClose;

  @override
  State<_SolveStepsModal> createState() => _SolveStepsModalState();
}

class _SolveStepsModalState extends State<_SolveStepsModal> {
  static const _animationDuration = Duration(milliseconds: 260);

  int _currentStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    final steps = widget.solution.steps;
    final currentStep = steps[_currentStepIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Passo a passo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                key: const Key('solve_steps_modal_close_button'),
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Passo ${_currentStepIndex + 1} de ${steps.length}',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: _animationDuration,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0.18, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: _SolveStepCard(
                  key: ValueKey(_currentStepIndex),
                  step: currentStep,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('solve_steps_previous_button'),
                  onPressed: _currentStepIndex == 0
                      ? null
                      : () => setState(() => _currentStepIndex -= 1),
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Anterior'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.selected,
                    side: const BorderSide(color: AppColors.selected),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  key: const Key('solve_steps_next_button'),
                  onPressed: _currentStepIndex >= steps.length - 1
                      ? widget.onClose
                      : () => setState(() => _currentStepIndex += 1),
                  icon: Icon(
                    _currentStepIndex >= steps.length - 1
                        ? Icons.check
                        : Icons.chevron_right,
                  ),
                  label: Text(
                    _currentStepIndex >= steps.length - 1
                        ? 'Concluir'
                        : 'Proximo',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.selected,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SolveStepCard extends StatelessWidget {
  const _SolveStepCard({super.key, required this.step});

  final EquationSolveStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.rule,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.selected.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Antes',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step.before,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.selected.withValues(alpha: 0.22),
                ),
                const SizedBox(height: 12),
                Text(
                  'Depois',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step.after,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
