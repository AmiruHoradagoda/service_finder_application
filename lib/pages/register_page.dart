import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/components/my_button.dart';
import 'package:service_finder_application/components/my_textfield.dart';
import 'package:service_finder_application/helper/helper_functions.dart';
import 'package:service_finder_application/pages/provider_register_page.dart';

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

  void registerUser() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      displayMessageToUser("Passwords don't Match!", context);
    } else {
      try {
        UserCredential? userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        createUserDocument(userCredential);
        if (context.mounted) Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        displayMessageToUser(e.code, context);
      }
    }
  }

  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'user_ID': userCredential.user!.uid,
        'email': userCredential.user!.email,
        'username': userNameController.text,
        'provider': false, // Set 'provider' to false by default
      });
    }
  }

  void goToProviderRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProviderRegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Get screen size

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image at the top covering the screen width (Full width, 35% height of screen)
            Container(
              width: size.width,
              height: size.height * 0.35, // 35% of the screen height
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover, // Image will cover the container
                  image: AssetImage('assets/images/service-provider-login.png'),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
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
                        onTap: goToProviderRegisterPage,
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
