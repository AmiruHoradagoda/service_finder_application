import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/components/my_button.dart';
import 'package:service_finder_application/components/my_textfield.dart';
import 'package:service_finder_application/helper/helper_functions.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Get screen size

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image at the top covering the screen width (Full width, 35% height of screen)
            Container(
              width: size.width,
              height: size.height * 0.35, // 35% of the screen height
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover, // Image will cover the container
                  image: AssetImage('assets/images/service-provider-login.png'),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20), // Adjust space from top
                  const Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Dark text for readability
                    ),
                  ),
                  const Text(
                    "Connect With Your User Account",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54, // Lighter text for subheading
                    ),
                  ),
                  const SizedBox(height: 30),
                  MyTextField(
                    hintText: "Email",
                    obscureText: false,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    icon: const Icon(Icons.email, color: Colors.blue),
                  ),
                  const SizedBox(height: 15),
                  MyTextField(
                    hintText: "Password",
                    obscureText: true,
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    icon: const Icon(Icons.lock, color: Colors.blue),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Forgot Password?",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  MyButton(
                    onTap: login,
                    text: "Login",
                    color: Colors.blue, 
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          " Register Here.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
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
