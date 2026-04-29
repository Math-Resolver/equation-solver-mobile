import '../core/core.dart';
import '../state/structured_math_node.dart';

class FractionNode extends StructuredMathNode {
  final RowNode numerator;
  final RowNode denominator;

  const FractionNode({
    required String id,
    required this.numerator,
    required this.denominator,
  }) : super(id);

  @override
  List<SlotRef> get slots => [
        SlotRef(name: 'numerator', row: numerator),
        SlotRef(name: 'denominator', row: denominator),
      ];

  @override
  FractionNode copyWithSlot(String slotName, RowNode row) {
    switch (slotName) {
      case 'numerator':
        return FractionNode(id: id, numerator: row, denominator: denominator);
      case 'denominator':
        return FractionNode(id: id, numerator: numerator, denominator: row);
      default:
        return this;
    }
  }
}
