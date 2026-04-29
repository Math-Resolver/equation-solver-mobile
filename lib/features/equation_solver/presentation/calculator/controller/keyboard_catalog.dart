import '../services/math_editor_reducer.dart';
import 'keyboard_models.dart';

class KeyboardCatalog {
  static const Map<String, KeyboardType> keyboards = {
    'basic': KeyboardType(
      id: 'basic',
      label: '+ - x ÷',
      symbols: {
        '+', '-', '×', '÷', '=', '1/', '>', 'x',
        'π', '%', ',',
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
      },
      structures: [
        KeyboardStructure(label: '( )', action: MathStructureType.parentheses),
        KeyboardStructure(label: '□/□', action: MathStructureType.fraction),
        KeyboardStructure(label: '|□|', action: MathStructureType.absolute),
        KeyboardStructure(label: '√', action: MathStructureType.root),
        KeyboardStructure(label: '□²', action: MathStructureType.power),
      ],
      orderedLayout: [
        '( )', '+', '÷', '7', '8', '9',
        '□/□', '|□|', 'x', '4', '5', '6',
        '□²', '>', '-', '1', '2', '3',
        'π', '%', '×', '0', ',', '=',
      ],
    ),
    'functions': KeyboardType(
      id: 'functions',
      label: 'f(x) e log ln',
      symbols: {
        'f(x)', 'log₁₀', 'i', 'log₂', 'P', 'z', '!',
        'e', 'f(x,y)', 'C', 'Z̄', 'exp', '%', 'ln', 'sign',
      },
      structures: [
        KeyboardStructure(label: '□/□', action: MathStructureType.fraction),
        KeyboardStructure(label: '□^□', action: MathStructureType.power),
        KeyboardStructure(label: '( )', action: MathStructureType.parentheses),
        KeyboardStructure(label: '□( )', action: MathStructureType.parentheses),
        KeyboardStructure(label: '□√□', action: MathStructureType.root),
        KeyboardStructure(label: 'log□', action: MathStructureType.parentheses),
        KeyboardStructure(label: '|□|', action: MathStructureType.absolute),
        KeyboardStructure(label: '⌈□⌉', action: MathStructureType.parentheses),
        KeyboardStructure(label: '⌊□⌋', action: MathStructureType.parentheses),
      ],
      orderedLayout: [
        '|□|', 'f(x)', 'log₁₀', '□V□', 'i', '□,□,□',
        '□^□', '□(□)', 'log₂', 'P', 'z', '!',
        'e', 'f(x,y)', 'log□', 'C', 'Z̄', '⌈□⌉',
        'exp', '%', 'ln', '(□□)', 'sign', '⌊□⌋',
      ],
    ),
    'trig': KeyboardType(
      id: 'trig',
      label: 'sin cos tan cot',
      symbols: {
        'rad', 'sin', 'cos', 'tan', 'cot',
        'csc', 'arcsin', 'arccos', 'arctan',
        'arccot', 'arcsec', 'sinh', 'cosh',
        'tanh', 'coth', 'sech', 'arsinh',
        'arcosh', 'artanh', 'arcoth', 'arcsech',
      },
      orderedLayout: [
        'rad', 'sin', 'cos', 'tan', 'cot',
        'csc', 'arcsin', 'arccos', 'arctan',
        'arccot', 'arcsec', 'sinh', 'cosh',
        'tanh', 'coth', 'sech', 'arsinh',
        'arcosh', 'artanh', 'arcoth', 'arcsech',
      ],
    ),
    'calculus': KeyboardType(
      id: 'calculus',
      label: 'lim dx ∑ ∫ ∞',
      symbols: {'lim', 'd/dx', '∫', 'dy/dx', 'd/d', 'Σ', '∞', '!'},
      orderedLayout: ['lim', 'd/dx', '∫', 'dy/dx', 'd/d', 'Σ', '∞', '!'],
    ),
    'abc': KeyboardType(
      id: 'abc',
      label: 'ABC',
      symbols: {
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
        'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
      },
      orderedLayout: [
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
        'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
      ],
    ),
  };

  static const List<String> keyboardOrder = [
    'basic',
    'functions',
    'trig',
    'calculus',
    'abc',
  ];
}
