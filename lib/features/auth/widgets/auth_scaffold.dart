import 'package:flutter/material.dart';
import 'package:service_finder_application/features/auth/widgets/auth_illustration.dart';

const authAccent = Color(0xFF087F88);

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.headline, required this.child});
  final String headline;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF10292C) : const Color(0xFFE2F5F5),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 600;
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: wide ? 24 : 0, vertical: wide ? 24 : 0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(wide ? 32 : 0),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF24BDC5), Color(0xFF129BA8)]),
                    ),
                    child: CustomScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        SliverToBoxAdapter(
                            child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  if (Navigator.of(context).canPop())
                                    const BackButton(color: Colors.white)
                                  else ...[
                                    const Icon(
                                        Icons.home_repair_service_outlined,
                                        color: Colors.white,
                                        size: 22),
                                    const SizedBox(width: 9),
                                  ],
                                  const Expanded(
                                      child: Text('Service Finder',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600))),
                                ]),
                                const SizedBox(height: 18),
                                Text(headline,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 27,
                                      height: 1.2,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.7,
                                    )),
                                const SizedBox(height: 6),
                                const SizedBox(
                                    height: 124,
                                    width: double.infinity,
                                    child: AuthIllustration()),
                              ]),
                        )),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Material(
                            color:
                                dark ? const Color(0xFF172A2D) : Colors.white,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(34)),
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 28, 24, 30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [child],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
