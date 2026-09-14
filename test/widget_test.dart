import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_finder_application/features/auth/screens/login_or_register.dart';
import 'package:service_finder_application/features/auth/screens/login_page.dart';
import 'package:service_finder_application/features/auth/screens/register_page.dart';
import 'package:service_finder_application/routes/app_routes.dart';

void main() {
  test('Existing named routes remain available', () {
    expect(
        AppRoutes.routes.keys,
        unorderedEquals([
          '/login_register_page',
          '/home_page',
          '/profile_page',
          '/users_page',
        ]));
  });

  testWidgets('Login and registration navigation still works', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      initialRoute: AppRoutes.loginRegister,
      routes: AppRoutes.routes,
    ));
    await tester.pumpAndSettle();
    expect(find.byType(LoginOrRegister), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);

    await tester.tap(find.text(' Register Here.'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsOneWidget);

    await tester.tap(find.text(' Login Here.'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
