import 'math_node.dart';

class RowNode extends MathNode {
  final List<MathNode> children;

  const RowNode({required String id, required this.children}) : super(id);

  RowNode copyWith({List<MathNode>? children}) {
    return RowNode(id: id, children: children ?? this.children);
  }
}
