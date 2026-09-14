import 'package:flutter/material.dart';
import 'package:service_finder_application/features/auth/widgets/auth_input.dart';
import 'package:service_finder_application/features/auth/widgets/auth_scaffold.dart';
import 'package:service_finder_application/features/auth/widgets/auth_submit_button.dart';

class RegistrationForm extends StatelessWidget {
  const RegistrationForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onRegister,
    required this.onLogin,
    this.onProviderRegister,
    this.provider = false,
    this.agreedToTerms = false,
    this.onTermsChanged,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController,
      emailController,
      passwordController,
      confirmPasswordController;
  final VoidCallback onRegister;
  final VoidCallback? onLogin, onProviderRegister;
  final bool provider, agreedToTerms;
  final ValueChanged<bool?>? onTermsChanged;

  @override
  Widget build(BuildContext context) => AutofillGroup(
        child: Form(
          key: formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(provider ? 'Join as a provider' : 'Sign up',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.7)),
            const SizedBox(height: 4),
            Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Already have an account?',
                      style: TextStyle(
                          fontSize: 13,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  TextButton(
                      onPressed: onLogin,
                      style: TextButton.styleFrom(foregroundColor: authAccent),
                      child: const Text(' Login Here.')),
                ]),
            const SizedBox(height: 18),
            AuthInput(
                controller: usernameController,
                label: 'Your name',
                icon: Icons.person_outline_rounded,
                autofillHints: const [AutofillHints.name],
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter your name.'
                    : null),
            const SizedBox(height: 14),
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
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter a password.'
                    : null),
            const SizedBox(height: 14),
            AuthInput(
                controller: confirmPasswordController,
                label: 'Confirm password',
                icon: Icons.lock_outline_rounded,
                password: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onRegister(),
                validator: (value) => value == null || value.isEmpty
                    ? 'Confirm your password.'
                    : null),
            if (provider) ...[
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: authAccent,
                value: agreedToTerms,
                onChanged: onTermsChanged,
                title: const Text('I agree to the terms and conditions',
                    style: TextStyle(fontSize: 13)),
              ),
            ],
            const SizedBox(height: 24),
            AuthSubmitButton(label: 'Create account', onPressed: onRegister),
            if (!provider) ...[
              const SizedBox(height: 14),
              TextButton.icon(
                onPressed: onProviderRegister,
                style: TextButton.styleFrom(foregroundColor: authAccent),
                icon: const Icon(Icons.home_repair_service_outlined, size: 18),
                label: const Text(' Become a Provider.'),
              ),
            ],
          ]),
        ),
      );
}
