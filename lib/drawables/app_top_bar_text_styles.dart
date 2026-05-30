import 'package:flutter/material.dart';

class AppTopBarTextStyles {
  const AppTopBarTextStyles._();

  static TextStyle title({required Color color}) {
    return TextStyle(
      color: color,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.05,
    );
  }

  static TextStyle action({required Color color}) {
    return TextStyle(
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.1,
    );
  }
}
