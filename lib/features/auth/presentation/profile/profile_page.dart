import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/core/localization/app_text_key.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmailController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    super.dispose();
  }

  void _onLoginSubmit(BuildContext context) {
    final locale = AppLocalizationScope.of(context);
    if (_loginFormKey.currentState?.validate() != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.text(AppTextKey.profileLoginError))),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(locale.text(AppTextKey.profileLoginError))),
    );
  }

  void _onRegisterSubmit(BuildContext context) {
    final locale = AppLocalizationScope.of(context);
    if (_registerFormKey.currentState?.validate() != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.text(AppTextKey.profileRegisterError))),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(locale.text(AppTextKey.profileRegisterError))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizationScope.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0E4F95),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E4F95),
        elevation: 0,
        centerTitle: true,
        title: Text(
          locale.text(AppTextKey.profileTitle),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: locale.text(AppTextKey.profileLoginTab)),
            Tab(text: locale.text(AppTextKey.profileRegisterTab)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LoginTab(
            formKey: _loginFormKey,
            emailController: _loginEmailController,
            onSubmit: _onLoginSubmit,
          ),
          _RegisterTab(
            formKey: _registerFormKey,
            nameController: _registerNameController,
            emailController: _registerEmailController,
            onSubmit: _onRegisterSubmit,
          ),
        ],
      ),
    );
  }
}

class _LoginTab extends StatelessWidget {
  const _LoginTab({
    required this.formKey,
    required this.emailController,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final void Function(BuildContext context) onSubmit;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizationScope.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: locale.text(AppTextKey.profileEmail),
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => onSubmit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0E4F95),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                locale.text(AppTextKey.profileLoginButton),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterTab extends StatelessWidget {
  const _RegisterTab({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final void Function(BuildContext context) onSubmit;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizationScope.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            TextFormField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: locale.text(AppTextKey.profileName),
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: locale.text(AppTextKey.profileEmail),
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => onSubmit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0E4F95),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                locale.text(AppTextKey.profileRegisterButton),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
