import 'package:flutter/material.dart';
import 'package:service_finder_application/features/auth/services/auth_service.dart';
import 'package:service_finder_application/features/auth/models/registration_data.dart';
import 'package:service_finder_application/shared/widgets/my_button.dart';
import 'package:service_finder_application/shared/widgets/my_textfield.dart';
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
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _agreedToTerms = false;

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      displayMessageToUser("Passwords don't match!", context);
      return;
    }
    if (!_agreedToTerms) {
      displayMessageToUser(
          "You must agree to the terms and conditions", context);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Registration')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Provider Registration",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  hintText: "User Name",
                  obscureText: false,
                  controller: userNameController,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  hintText: "Confirm Password",
                  obscureText: true,
                  controller: confirmPasswordController,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value!;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "I agree to the terms and conditions",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                MyButton(
                  onTap: registerUser,
                  text: "Register",
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    GestureDetector(
                      onTap: widget.onLogin,
                      child: const Text(
                        " Login Here.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
