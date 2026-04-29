import '../core/core.dart';

abstract class StructuredMathNode extends MathNode {
  const StructuredMathNode(super.id);

  List<SlotRef> get slots;

  String get primarySlotName => slots.first.name;

  String? nextSlotName(String currentSlotName) {
    final index = slots.indexWhere((slot) => slot.name == currentSlotName);
    if (index == -1 || index + 1 >= slots.length) {
      return null;
    }
    return slots[index + 1].name;
  }

  String? previousSlotName(String currentSlotName) {
    final index = slots.indexWhere((slot) => slot.name == currentSlotName);
    if (index <= 0) {
      return null;
    }
    return slots[index - 1].name;
  }

  RowNode? rowForSlot(String slotName) {
    for (final slot in slots) {
      if (slot.name == slotName) {
        return slot.row;
      }
    }
    return null;
  }

  StructuredMathNode copyWithSlot(String slotName, RowNode row);
}
