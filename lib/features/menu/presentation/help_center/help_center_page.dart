import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/drawables/app_top_bar_text_styles.dart';
import 'package:equation_solver_mobile/features/menu/presentation/languages/language_selection_page.dart';
import 'package:flutter/material.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  static const _pageColor = Color(0xFF0E4F95);
  static const _faqHeaderColor = Color(0xFFF2F2F2);
  static const _faqBodyColor = Color(0xFF9FD7EE);
  static const _faqTextColor = Color(0xFF0B4B92);
  static const _hintColor = Color(0xFF9F9F9F);

  static const _faqItems = <_FaqItem>[
    _FaqItem(
      question: 'Como funciona?',
      answer:
          'Use a camera para capturar a equação ou digite manualmente na calculadora. O app processa a expressão e mostra o resultado com os passos de resolução.',
    ),
    _FaqItem(
      question: 'Como funciona o chatbot?',
      answer:
          'O Killbot explica tópicos de matemática por assunto. Escolha um tópico, leia a explicação e peça mais exemplos quando quiser aprofundar.',
    ),
    _FaqItem(
      question: 'Não tá resolvendo o cálculo!',
      answer:
          'Confira se a equação está legível e bem escrita. Se necessário, ajuste manualmente o texto reconhecido e tente novamente. Também verifique sua conexão com a internet.',
    ),
  ];

  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final localeController = AppLocalizationScope.of(context);

    return Scaffold(
      backgroundColor: _pageColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTopBar(context),
                        const SizedBox(height: 22),
                        _buildLogo(),
                        const SizedBox(height: 16),
                        const Text(
                          'Como podemos te ajudar?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildMessageField(),
                        const SizedBox(height: 22),
                        ...List.generate(_faqItems.length, _buildFaqItem),
                        const Spacer(),
                        _buildLanguageSelector(
                          localeController.currentLanguageName,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 54),
        Expanded(
          child: Text(
            'Centro de ajuda',
            textAlign: TextAlign.center,
            style: AppTopBarTextStyles.title(color: Colors.white),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            'Fechar',
            style: AppTopBarTextStyles.action(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E5BAB), Color(0xFF0A3E77)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.asset('assets/images/killmath_logo.png'),
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Mande uma mensagem para nossa equipe',
        hintStyle: const TextStyle(
          color: _hintColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: const Icon(Icons.search, color: _hintColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFaqItem(int index) {
    final isExpanded = _expandedIndex == index;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Color(0xFF1B6DAB), width: 1),
          right: BorderSide(color: Color(0xFF1B6DAB), width: 1),
          bottom: BorderSide(color: Color(0xFF1B6DAB), width: 1),
        ),
      ),
      child: Column(
        children: [
          Material(
            color: _faqHeaderColor,
            child: InkWell(
              onTap: () {
                setState(() {
                  _expandedIndex = isExpanded ? null : index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _faqItems[index].question,
                        style: const TextStyle(
                          color: _faqTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: _faqTextColor,
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isExpanded
                ? Container(
                    key: ValueKey('faq-body-$index'),
                    width: double.infinity,
                    color: _faqBodyColor,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    child: Text(
                      _faqItems[index].answer,
                      style: TextStyle(
                        color: _faqTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('faq-body-empty')),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(String languageName) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LanguageSelectionPage()),
          );
        },
        child: Container(
          width: 170,
          padding: const EdgeInsets.fromLTRB(10, 6, 8, 8),
          decoration: BoxDecoration(border: Border.all(color: Colors.white70)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '- Idioma',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      languageName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}
