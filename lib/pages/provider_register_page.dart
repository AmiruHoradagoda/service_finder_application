import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/components/my_button.dart';
import 'package:service_finder_application/components/my_textfield.dart';
import 'package:service_finder_application/helper/helper_functions.dart';
import 'package:service_finder_application/pages/home_page.dart';

class ProviderRegisterPage extends StatefulWidget {
  const ProviderRegisterPage({super.key});

  @override
  State<ProviderRegisterPage> createState() => _ProviderRegisterPageState();
}

class _ProviderRegisterPageState extends State<ProviderRegisterPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nicController = TextEditingController();

  bool _agreedToTerms = false;

  void registerUser() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      displayMessageToUser("Passwords don't Match!", context);
    } else if (!_agreedToTerms) {
      Navigator.pop(context);
      displayMessageToUser(
          "You must agree to the terms and conditions", context);
    } else {
      try {
        UserCredential? userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        createUserDocument(userCredential);

        if (context.mounted) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
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
          .doc(userCredential.user!
              .email) // You can still use email as document ID or switch to user.uid
          .set({
        'user_ID': userCredential.user!.uid, // Add the user_ID field
        'email': userCredential.user!.email,
        'username': userNameController.text,
        'nic': nicController.text,
        'provider': true,
      });
    }
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "B E C O M E   A   P R O V I D E R",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  hintText: "User Name",
                  obscureText: false,
                  controller: userNameController,
                  keyboardType: TextInputType.text, // Added keyboardType
                ),
                const SizedBox(height: 10),
                MyTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController,
                  keyboardType:
                      TextInputType.emailAddress, // Added keyboardType
                ),
                const SizedBox(height: 10),
                MyTextField(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController,
                  keyboardType: TextInputType.text, // Added keyboardType
                ),
                const SizedBox(height: 10),
                MyTextField(
                  hintText: "Confirm Password",
                  obscureText: true,
                  controller: confirmPasswordController,
                  keyboardType: TextInputType.text, // Added keyboardType
                ),
                const SizedBox(height: 10),
                MyTextField(
                  hintText: "NIC Number",
                  obscureText: false,
                  controller: nicController,
                  keyboardType: TextInputType.text, // Added keyboardType
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      checkColor: Colors.grey.shade900,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value!;
                        });
                      },
                    ),
                    const Text("Agreed to the terms and conditions")
                  ],
                ),
                const SizedBox(height: 10),
                MyButton(onTap: registerUser, text: "Register"),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
