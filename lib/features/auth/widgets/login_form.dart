import 'package:flutter/material.dart';
import 'package:service_finder_application/features/auth/widgets/auth_input.dart';
import 'package:service_finder_application/features/auth/widgets/auth_scaffold.dart';
import 'package:service_finder_application/features/auth/widgets/auth_submit_button.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSignIn,
    required this.onRegister,
    required this.isSubmitting,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSignIn;
  final VoidCallback? onRegister;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) => AutofillGroup(
        child: Form(
          key: formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.7)),
            const SizedBox(height: 4),
            Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('New here?',
                      style: TextStyle(
                          fontSize: 13,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  TextButton(
                    onPressed: isSubmitting ? null : onRegister,
                    style: TextButton.styleFrom(foregroundColor: authAccent),
                    child: const Text('Create an account'),
                  ),
                ]),
            const SizedBox(height: 20),
            AuthInput(
                controller: emailController,
                label: 'Email address',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: validateAuthEmail),
            const SizedBox(height: 14),
            AuthInput(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                password: true,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!isSubmitting) onSignIn();
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your password.'
                    : null),
            const SizedBox(height: 28),
            AuthSubmitButton(
                label: 'Login', onPressed: onSignIn, busy: isSubmitting),
            const SizedBox(height: 22),
            Text('A little help. A stronger community.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ),
      );
}
