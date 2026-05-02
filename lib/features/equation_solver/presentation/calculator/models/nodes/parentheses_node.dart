import '../core/core.dart';
import '../state/structured_math_node.dart';

class ParenthesesNode extends StructuredMathNode {
  final RowNode content;

  const ParenthesesNode({required String id, required this.content}) : super(id);

  @override
  List<SlotRef> get slots => [SlotRef(name: 'content', row: content)];

  @override
  ParenthesesNode copyWithSlot(String slotName, RowNode row) {
    if (slotName == 'content') {
      return ParenthesesNode(id: id, content: row);
    }
    return this;
  }
}
