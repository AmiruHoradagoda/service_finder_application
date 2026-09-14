import 'package:flutter/material.dart';

class AuthBanner extends StatelessWidget {
  const AuthBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
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
    );
  }
}
