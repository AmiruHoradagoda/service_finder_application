import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_finder_application/features/auth/services/auth_service.dart';
import 'package:service_finder_application/features/auth/widgets/login_form.dart';
import 'package:service_finder_application/features/auth/widgets/auth_scaffold.dart';
import 'package:service_finder_application/routes/auth_navigation.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> login() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    final email = emailController.text.trim();
    final password = passwordController.text;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      await context.read<AuthNavigation>().authenticate(context, () async {
        await AuthService().signIn(email: email, password: password);
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
        headline: 'Log in and find the\nhelp you need.',
        child: LoginForm(
          formKey: _formKey,
          emailController: emailController,
          passwordController: passwordController,
          onSignIn: login,
          onRegister: widget.onTap,
          isSubmitting: _isSubmitting,
        ),
      );
}
