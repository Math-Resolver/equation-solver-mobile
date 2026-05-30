import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/core/localization/app_text_key.dart';
import 'package:equation_solver_mobile/dependencies.dart';
import 'package:equation_solver_mobile/drawables/app_colors.dart';
import 'package:equation_solver_mobile/drawables/app_top_bar_text_styles.dart';
import 'package:equation_solver_mobile/features/auth/presentation/profile/profile_page_controller.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.controller});

  final ProfilePageController? controller;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    {
  static const Duration _modeTransitionDuration = Duration(milliseconds: 280);

  late ProfilePageController _controller;
  late bool _ownsController;
  bool _isLoginMode = true;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        ProfilePageController(
          authRepository: AppDependencies.instance.authRepository,
          passkeyClient: AppDependencies.instance.passkeyClient,
        );
    _ownsController = widget.controller == null;
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onLoginSubmit(BuildContext context) async {
    if (_controller.isSubmitting) {
      return;
    }

    final locale = AppLocalizationScope.of(context);
    final result = await _controller.loginWithPasskey();
    if (!context.mounted) {
      return;
    }

    final message = switch (result) {
      ProfileSubmitStatus.success => locale.text(
        AppTextKey.profileLoginSuccess,
      ),
      ProfileSubmitStatus.passkeyUnavailable => locale.text(
        AppTextKey.profilePasskeyUnavailable,
      ),
      _ => locale.text(AppTextKey.profileLoginError),
    };
    _showSingleSnackBar(context, message);
  }

  Future<void> _onRegisterSubmit(BuildContext context) async {
    if (_controller.isSubmitting) {
      return;
    }

    final locale = AppLocalizationScope.of(context);
    final result = await _controller.registerWithPasskey();
    if (!context.mounted) {
      return;
    }

    final message = switch (result) {
      ProfileSubmitStatus.success => locale.text(
        AppTextKey.profileRegisterSuccess,
      ),
      ProfileSubmitStatus.passkeyUnavailable => locale.text(
        AppTextKey.profilePasskeyUnavailable,
      ),
      _ => locale.text(AppTextKey.profileRegisterError),
    };
    _showSingleSnackBar(context, message);
  }

  void _showSingleSnackBar(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onPrimarySubmit(BuildContext context) {
    if (_isLoginMode) {
      return _onLoginSubmit(context);
    }
    return _onRegisterSubmit(context);
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizationScope.of(context);
    final modeTitle = _isLoginMode
        ? locale.text(AppTextKey.profileLoginTab)
        : locale.text(AppTextKey.profileRegisterTab);
    final actionText = _isLoginMode
        ? locale.text(AppTextKey.profileLoginButton)
        : locale.text(AppTextKey.profileRegisterButton);
    final toggleText = _isLoginMode ? 'Ainda nao tem acesso?' : 'Ja tem acesso?';
    final toggleActionText = _isLoginMode
        ? locale.text(AppTextKey.profileRegisterTab)
        : locale.text(AppTextKey.profileLoginTab);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(context, modeTitle),
              const Spacer(),
              _buildLogo(),
              const SizedBox(height: 10),
              const Text(
                'killmath',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 40),
              AnimatedSlide(
                duration: _modeTransitionDuration,
                curve: Curves.easeOutCubic,
                offset: _isLoginMode ? Offset.zero : const Offset(0.02, 0),
                child: ElevatedButton(
                  key: const Key('profile_primary_action_button'),
                  onPressed: _controller.isSubmitting
                      ? null
                      : () => _onPrimarySubmit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.selected,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _controller.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : AnimatedSwitcher(
                          duration: _modeTransitionDuration,
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            final offsetAnimation = Tween<Offset>(
                              begin: const Offset(0, 0.35),
                              end: Offset.zero,
                            ).animate(animation);
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            actionText,
                            key: ValueKey(actionText),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                key: const Key('profile_toggle_mode_button'),
                onPressed: _toggleMode,
                child: AnimatedSwitcher(
                  duration: _modeTransitionDuration,
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: RichText(
                    key: ValueKey('toggle-$toggleActionText'),
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFF4F4F4F),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(text: '$toggleText '),
                        TextSpan(
                          text: toggleActionText,
                          style: const TextStyle(
                            color: AppColors.selected,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String modeTitle) {
    final locale = AppLocalizationScope.of(context);
    return Row(
      children: [
        const SizedBox(width: 52),
        Expanded(
          child: AnimatedSwitcher(
            duration: _modeTransitionDuration,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            child: Text(
              modeTitle,
              key: ValueKey(modeTitle),
              textAlign: TextAlign.center,
              style: AppTopBarTextStyles.title(color: Colors.black),
            ),
          ),
        ),
        GestureDetector(
          key: const Key('profile_close_button'),
          onTap: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : Navigator.of(context).pushReplacementNamed('/camera'),
          child: Text(
            locale.text(AppTextKey.calculatorClose),
            style: AppTopBarTextStyles.action(color: AppColors.selected),
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
}
