import 'package:service_finder_application/features/auth/widgets/auth_scaffold.dart';
import 'package:service_finder_application/features/auth/widgets/registration_form.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/features/auth/services/auth_service.dart';
import 'package:service_finder_application/features/auth/models/registration_data.dart';
import 'package:service_finder_application/core/utils/helper_functions.dart';
import 'package:provider/provider.dart';
import 'package:service_finder_application/routes/auth_navigation.dart';

class ProviderRegisterPage extends StatefulWidget {
  final VoidCallback onLogin;

  const ProviderRegisterPage({super.key, required this.onLogin});

  @override
  State<ProviderRegisterPage> createState() => _ProviderRegisterPageState();
}

class _ProviderRegisterPageState extends State<ProviderRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _agreedToTerms = false;

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (passwordController.text != confirmPasswordController.text) {
      displayMessageToUser("Passwords don't match!", context,
          type: MessageType.warning);
      return;
    }
    if (!_agreedToTerms) {
      displayMessageToUser(
          "You must agree to the terms and conditions", context,
          type: MessageType.warning);
      return;
    }
    await context.read<AuthNavigation>().authenticate(context, () async {
      await AuthService().register(
        registration: RegistrationData(
          username: userNameController.text,
          email: emailController.text,
          isProvider: true,
        ),
        password: passwordController.text,
      );
    });
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
        headline: 'Share your skills.\nGrow your business.',
        child: RegistrationForm(
          formKey: _formKey,
          usernameController: userNameController,
          emailController: emailController,
          passwordController: passwordController,
          confirmPasswordController: confirmPasswordController,
          onRegister: registerUser,
          onLogin: widget.onLogin,
          provider: true,
          agreedToTerms: _agreedToTerms,
          onTermsChanged: (value) =>
              setState(() => _agreedToTerms = value ?? false),
        ),
      );
}
