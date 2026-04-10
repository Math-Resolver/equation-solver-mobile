import 'package:flutter/material.dart';

class CalculatorCategoryTabs extends StatefulWidget {
  const CalculatorCategoryTabs({super.key});

  @override
  State<CalculatorCategoryTabs> createState() =>
      _CalculatorCategoryTabsState();
}

class _CalculatorCategoryTabsState extends State<CalculatorCategoryTabs> {
  int selectedIndex = 0;

  final tabs = [
    "+ − × ÷",
    "f(x) e log ln",
    "sin cos tan",
    "∫ Σ lim",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => selectedIndex = index);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}