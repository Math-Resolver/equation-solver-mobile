import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/core/localization/app_text_key.dart';
import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = AppLocalizationScope.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0E4F95),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E4F95),
        elevation: 0,
        centerTitle: true,
        title: Text(localeController.text(AppTextKey.helpCenterTitle)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            localeController.text(AppTextKey.helpCenterPlaceholder),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
