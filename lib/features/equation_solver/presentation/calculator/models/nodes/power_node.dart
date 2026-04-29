import '../core/core.dart';
import '../state/structured_math_node.dart';

class PowerNode extends StructuredMathNode {
  final RowNode base;
  final RowNode exponent;

  const PowerNode({
    required String id,
    required this.base,
    required this.exponent,
  }) : super(id);

  @override
  List<SlotRef> get slots => [
        SlotRef(name: 'base', row: base),
        SlotRef(name: 'exponent', row: exponent),
      ];

  @override
  PowerNode copyWithSlot(String slotName, RowNode row) {
    switch (slotName) {
      case 'base':
        return PowerNode(id: id, base: row, exponent: exponent);
      case 'exponent':
        return PowerNode(id: id, base: base, exponent: row);
      default:
        return this;
    }
  }
}
