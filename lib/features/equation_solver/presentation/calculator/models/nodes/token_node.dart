import '../core/core.dart';

class TokenNode extends MathNode {
  final String value;

  const TokenNode({required String id, required this.value}) : super(id);
}
