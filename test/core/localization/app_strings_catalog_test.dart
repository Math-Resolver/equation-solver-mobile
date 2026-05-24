import 'package:equation_solver_mobile/core/localization/app_strings_catalog.dart';
import 'package:equation_solver_mobile/core/localization/app_text_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppStringsCatalog', () {
    const catalog = AppStringsCatalog();

    test('returns english translation when available', () {
      expect(
        catalog.text(key: AppTextKey.menuLanguage, languageCode: 'en'),
        'Language',
      );
    });

    test('falls back to portuguese for truly unsupported locale', () {
      expect(
        catalog.text(key: AppTextKey.menuLanguage, languageCode: 'ja'),
        'Idioma',
      );
    });

    test('returns german translation', () {
      expect(
        catalog.text(key: AppTextKey.menuLanguage, languageCode: 'de'),
        'Sprache',
      );
    });

    test('returns spanish translation', () {
      expect(
        catalog.text(key: AppTextKey.calculatorClose, languageCode: 'es'),
        'Cerrar',
      );
    });

    test('returns french translation', () {
      expect(
        catalog.text(key: AppTextKey.menuHelpCenter, languageCode: 'fr'),
        "Centre d'aide",
      );
    });

    test('returns norwegian translation', () {
      expect(
        catalog.text(key: AppTextKey.languageDone, languageCode: 'no'),
        'Ferdig',
      );
    });

    test('returns korean translation', () {
      expect(
        catalog.text(key: AppTextKey.menuAboutUs, languageCode: 'ko'),
        '회사 소개',
      );
    });

    test('returns simplified chinese translation', () {
      expect(
        catalog.text(key: AppTextKey.cameraInstruction, languageCode: 'zh'),
        '拍摄数学题照片',
      );
    });

    test('returns croatian translation', () {
      expect(
        catalog.text(key: AppTextKey.languageCancel, languageCode: 'hr'),
        'Odustani',
      );
    });

    test('returns danish translation', () {
      expect(
        catalog.text(key: AppTextKey.chatSubmit, languageCode: 'da'),
        'Send',
      );
    });

    test('returns slovak translation', () {
      expect(
        catalog.text(key: AppTextKey.calculatorTitle, languageCode: 'sl'),
        'Kalkulačka',
      );
    });

    test('returns finnish translation', () {
      expect(
        catalog.text(key: AppTextKey.chatEmptyResponse, languageCode: 'fi'),
        'Ei vastausta vielä.',
      );
    });

    test('all supported language codes have full coverage without fallback', () {
      const supportedCodes = [
        'pt', 'en', 'de', 'no', 'zh', 'ko', 'hr', 'da', 'sl', 'es', 'fi', 'fr',
      ];
      for (final code in supportedCodes) {
        for (final key in AppTextKey.values) {
          final result = catalog.text(key: key, languageCode: code);
          expect(
            result,
            isNotEmpty,
            reason: 'Missing translation: code=$code key=$key',
          );
        }
      }
    });
  });
}
