import 'package:service_finder_application/features/auth/widgets/auth_banner.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/features/auth/services/auth_service.dart';
import 'package:service_finder_application/features/auth/models/registration_data.dart';
import 'package:service_finder_application/shared/widgets/my_button.dart';
import 'package:service_finder_application/shared/widgets/my_textfield.dart';
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
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      displayMessageToUser("Passwords don't Match!", context);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image at the top covering the screen width (Full width, 35% height of screen)
            const AuthBanner(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Sign Up With Your User Account",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // User Name
                  MyTextField(
                    hintText: "Username",
                    obscureText: false,
                    controller: userNameController,
                    keyboardType: TextInputType.text,
                    icon: const Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),

                  // Email
                  MyTextField(
                    hintText: "Email",
                    obscureText: false,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    icon: const Icon(Icons.email, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),

                  // Password
                  MyTextField(
                    hintText: "Password",
                    obscureText: true,
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    icon: const Icon(Icons.lock, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),

                  // Confirm Password
                  MyTextField(
                    hintText: "Confirm Password",
                    obscureText: true,
                    controller: confirmPasswordController,
                    keyboardType: TextInputType.text,
                    icon: const Icon(Icons.lock, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Register Button
                  MyButton(
                    onTap: registerUser,
                    text: "Register",
                    color: Colors.blue, // Set suitable color for the button
                  ),
                  const SizedBox(height: 30),

                  // Existing Account Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          " Login Here.",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Register as a Provider Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Register as a service provider?"),
                      GestureDetector(
                        onTap: () =>
                            AppRoutes.openProviderRegistration(context),
                        child: const Text(
                          " Become a Provider.",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
