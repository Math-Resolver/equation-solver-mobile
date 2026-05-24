import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/core/localization/app_text_key.dart';
import 'package:equation_solver_mobile/features/auth/presentation/profile/profile_page.dart';
import 'package:equation_solver_mobile/features/menu/presentation/about_us/about_us_page.dart';
import 'package:equation_solver_mobile/features/menu/presentation/help_center/help_center_page.dart';
import 'package:equation_solver_mobile/features/menu/presentation/languages/language_selection_page.dart';
import 'package:flutter/material.dart';

class EquationSolverAppDrawer extends StatelessWidget {
  const EquationSolverAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = AppLocalizationScope.of(context);

    return Drawer(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        color: const Color(0xFF0E4F95),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/killmath_logo.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Killmath',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Colors.white54),
              _DrawerMenuItem(
                icon: Icons.language,
                title: localeController.text(AppTextKey.menuLanguage),
                subtitle: localeController.currentLanguageName,
                onTap: () => _openPage(context, const LanguageSelectionPage()),
              ),
              _DrawerMenuItem(
                icon: Icons.person,
                title: localeController.text(AppTextKey.menuProfile),
                onTap: () => _openPage(context, const ProfilePage()),
              ),
              _DrawerMenuItem(
                icon: Icons.help,
                title: localeController.text(AppTextKey.menuHelpCenter),
                onTap: () => _openPage(context, const HelpCenterPage()),
              ),
              _DrawerMenuItem(
                icon: Icons.info,
                title: localeController.text(AppTextKey.menuAboutUs),
                onTap: () => _openPage(context, const AboutUsPage()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPage(BuildContext context, Widget page) async {
    Navigator.of(context).pop();
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: CircleAvatar(
        radius: 11,
        backgroundColor: Colors.white,
        child: Icon(icon, size: 14, color: const Color(0xFF0E4F95)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
      onTap: onTap,
    );
  }
}
