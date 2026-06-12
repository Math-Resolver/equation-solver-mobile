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

class _ProfilePageState extends State<ProfilePage> {
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
          tokenStorage: AppDependencies.instance.tokenStorage,
          deviceModelProvider: AppDependencies.instance.deviceModelProvider,
        );
    _ownsController = widget.controller == null;
    _controller.addListener(_onControllerChanged);
    _controller.loadAuthState();
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
    if (result == ProfileSubmitStatus.success) {
      await _showSuccessModalAndGoToCamera(
        context,
        locale.text(AppTextKey.profileSuccessRedirecting),
      );
    }
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
    if (result == ProfileSubmitStatus.success) {
      await _showSuccessModalAndGoToCamera(
        context,
        locale.text(AppTextKey.profileSuccessRedirecting),
      );
    }
  }

  Future<void> _showSuccessModalAndGoToCamera(
    BuildContext context,
    String message,
  ) async {
    if (!context.mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!context.mounted) {
      return;
    }

    Navigator.of(context, rootNavigator: true).pop();
    _goToCamera(context);
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    if (_controller.isSubmitting) {
      return;
    }

    await _controller.logout();
    if (!context.mounted) {
      return;
    }

    _showSingleSnackBar(
      context,
      AppLocalizationScope.of(context).text(AppTextKey.profileLogoutSuccess),
    );
    _goToCamera(context);
  }

  void _goToCamera(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacementNamed('/camera');
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

    if (_controller.isAuthStateLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_controller.isLoggedIn) {
      return Scaffold(
        backgroundColor: Colors.white,
        endDrawer: _ProfileMenuDrawer(onGoToCamera: () => _goToCamera(context)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLoggedTopBar(context),
                const Spacer(),
                _buildLogo(),
                const SizedBox(height: 14),
                Text(
                  locale.text(AppTextKey.profileLoggedInTitle),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${locale.text(AppTextKey.profileDeviceFingerprintLabel)}: ${_controller.deviceModel}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF4F4F4F),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  key: const Key('profile_logout_button'),
                  onPressed: _controller.isSubmitting
                      ? null
                      : () => _onLogoutPressed(context),
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
                      : Text(
                          locale.text(AppTextKey.profileLogoutButton),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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

    final modeTitle = _isLoginMode
        ? locale.text(AppTextKey.profileLoginTab)
        : locale.text(AppTextKey.profileRegisterTab);
    final actionText = _isLoginMode
        ? locale.text(AppTextKey.profileLoginButton)
        : locale.text(AppTextKey.profileRegisterButton);
    final toggleText = _isLoginMode
        ? 'Ainda nao tem acesso?'
        : 'Ja tem acesso?';
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
              const SizedBox(height: 8),
              const Text(
                'Killmath',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
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
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
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
                child: SlideTransition(position: offsetAnimation, child: child),
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

  Widget _buildLoggedTopBar(BuildContext context) {
    final locale = AppLocalizationScope.of(context);
    return Row(
      children: [
        const SizedBox(width: 52),
        Expanded(
          child: Text(
            locale.text(AppTextKey.menuProfile),
            textAlign: TextAlign.center,
            style: AppTopBarTextStyles.title(color: Colors.black),
          ),
        ),
        Builder(
          builder: (innerContext) => GestureDetector(
            key: const Key('profile_menu_button'),
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              locale.text(AppTextKey.calculatorClose),
              style: AppTopBarTextStyles.action(color: AppColors.selected),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E5BAB), Color(0xFF0A3E77)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset('assets/images/killmath_logo.png'),
        ),
      ),
    );
  }
}

class _ProfileMenuDrawer extends StatelessWidget {
  const _ProfileMenuDrawer({required this.onGoToCamera});

  final VoidCallback onGoToCamera;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ir para câmera'),
              onTap: () {
                Navigator.of(context).pop();
                onGoToCamera();
              },
            ),
          ],
        ),
      ),
    );
  }
}
