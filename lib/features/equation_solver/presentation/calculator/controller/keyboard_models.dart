import '../services/math_editor_reducer.dart';

class KeyboardStructure {
  final String label;
  final MathStructureType action;

  const KeyboardStructure({required this.label, required this.action});
}

class KeyboardType {
  final String id;
  final String label;
  final Set<String> symbols;
  final List<KeyboardStructure> structures;
  final List<String>? orderedLayout;

  const KeyboardType({
    required this.id,
    required this.label,
    required this.symbols,
    this.structures = const [],
    this.orderedLayout,
  });
}
