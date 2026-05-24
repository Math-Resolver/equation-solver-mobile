import 'package:equation_solver_mobile/core/localization/app_locale_controller.dart';
import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/core/localization/app_text_key.dart';
import 'package:flutter/material.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  AppLocaleController? _localeController;
  String? _pendingLanguageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localeController ??= AppLocalizationScope.of(context);
    _pendingLanguageCode ??= _localeController!.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final localeController = _localeController!;
    final options = localeController.supportedLanguageOptions;

    return Scaffold(
      backgroundColor: const Color(0xFF0E4F95),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const Divider(height: 1, color: Colors.white54),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: Colors.white54),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option.code == _pendingLanguageCode!;
                  return InkWell(
                    onTap: () => setState(() => _pendingLanguageCode = option.code),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            option.subtitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final localeController = _localeController!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              localeController.text(AppTextKey.languageCancel),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                localeController.text(AppTextKey.languageTitle),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _saveAndClose,
            child: Text(
              localeController.text(AppTextKey.languageDone),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndClose() async {
    await _localeController!.setLanguageCode(_pendingLanguageCode!);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
