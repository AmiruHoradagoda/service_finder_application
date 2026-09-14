import 'package:service_finder_application/features/auth/widgets/auth_scaffold.dart';
import 'package:service_finder_application/features/auth/widgets/registration_form.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/features/auth/services/auth_service.dart';
import 'package:service_finder_application/features/auth/models/registration_data.dart';
import 'package:service_finder_application/core/utils/helper_functions.dart';
import 'package:provider/provider.dart';
import 'package:service_finder_application/routes/app_routes.dart';
import 'package:service_finder_application/routes/auth_navigation.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (passwordController.text != confirmPasswordController.text) {
      displayMessageToUser("Passwords don't Match!", context,
          type: MessageType.warning);
      return;
    }
    await context.read<AuthNavigation>().authenticate(context, () async {
      await AuthService().register(
        registration: RegistrationData(
          username: userNameController.text,
          email: emailController.text,
          isProvider: false,
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
        headline: 'Create your account.\nFind your community.',
        child: RegistrationForm(
          formKey: _formKey,
          usernameController: userNameController,
          emailController: emailController,
          passwordController: passwordController,
          confirmPasswordController: confirmPasswordController,
          onRegister: registerUser,
          onLogin: widget.onTap,
          onProviderRegister: () => AppRoutes.openProviderRegistration(context),
        ),
      );
}
