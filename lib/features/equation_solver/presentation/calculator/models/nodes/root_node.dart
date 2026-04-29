import '../core/core.dart';
import '../state/structured_math_node.dart';

class RootNode extends StructuredMathNode {
  final RowNode radicand;

  const RootNode({required String id, required this.radicand}) : super(id);

  @override
  List<SlotRef> get slots => [SlotRef(name: 'radicand', row: radicand)];

  @override
  RootNode copyWithSlot(String slotName, RowNode row) {
    if (slotName == 'radicand') {
      return RootNode(id: id, radicand: row);
    }
    return this;
  }
}
