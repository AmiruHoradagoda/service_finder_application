import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:service_finder_application/features/auth/screens/login_screen.dart';
import 'package:service_finder_application/features/auth/screens/register_screen.dart';
import 'package:service_finder_application/features/auth/screens/provider_register_screen.dart';
import 'package:service_finder_application/features/chat/screens/chat_screen.dart';
import 'package:service_finder_application/features/posts/screens/open_post_screen.dart';
import 'package:service_finder_application/features/profile/screens/edit_profile_screen.dart';
import 'package:service_finder_application/routes/app_routes.dart';
import 'package:service_finder_application/routes/auth_navigation.dart';

/// Real guest routes, with a stand-in for Home's live Firebase-backed UI.
Widget navigationApp(AuthNavigation auth, NavigatorObserver observer) =>
    ChangeNotifierProvider.value(
      value: auth,
      child: Consumer<AuthNavigation>(
        builder: (context, auth, _) => MaterialApp(
          navigatorKey: auth.navigatorKey,
          navigatorObservers: [observer],
          onGenerateInitialRoutes: (_) => [
            auth.isSignedIn
                ? MaterialPageRoute<void>(
                    settings: const RouteSettings(name: AppRoutes.home),
                    builder: (_) =>
                        const Scaffold(body: Text('Signed-in home')),
                  )
                : AppRoutes.initialRoute(auth),
          ],
          onGenerateRoute: (_) => null,
        ),
      ),
    );

class RouteRecorder extends NavigatorObserver {
  Route<dynamic>? lastPushed;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastPushed = route;
  }
}

void main() {
  late StreamController<String?> sessions;
  late AuthNavigation auth;
  late RouteRecorder observer;

  setUp(() {
    sessions = StreamController<String?>.broadcast(sync: true);
    auth = AuthNavigation(sessions.stream);
    observer = RouteRecorder();
  });

  tearDown(() async {
    auth.dispose();
    await sessions.close();
  });

  Future<void> mount(WidgetTester tester, {String? userId}) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    sessions.add(userId);
    await tester.pumpWidget(navigationApp(auth, observer));
    await tester.pumpAndSettle();
  }

  Future<void> openProvider(WidgetTester tester) async {
    await tester.tap(find.text(' Register Here.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(' Become a Provider.'));
    await tester.pumpAndSettle();
  }

  test('Session restoration waits; repeated events preserve the current stack',
      () {
    expect(auth.isLoading, isTrue);
    expect(AppRoutes.initialRoute(auth).settings.name, AppRoutes.loading);
    sessions.add('user-a');
    expect(AppRoutes.initialRoute(auth).settings.name, AppRoutes.home);
    final firstKey = auth.navigatorKey;
    sessions.add('user-a');
    expect(auth.navigatorKey, same(firstKey));
    sessions.add('user-b');
    expect(auth.navigatorKey, isNot(same(firstKey)));
    sessions.add(null);
    expect(AppRoutes.initialRoute(auth).settings.name, AppRoutes.login);
  });

  testWidgets(
      'Register pushes; provider Back returns to Register; login returns to root',
      (tester) async {
    await mount(tester);
    await openProvider(tester);
    expect(find.byType(ProviderRegisterPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsOneWidget);

    await tester.tap(find.text(' Become a Provider.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(' Login Here.'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(auth.navigatorKey.currentState!.canPop(), isFalse);

    await tester.tap(find.text(' Register Here.'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Registration waits for the profile write and replaces the entire guest stack',
      (tester) async {
    await mount(tester);
    await openProvider(tester);
    final write = Completer<void>();
    final context = tester.element(find.byType(ProviderRegisterPage));
    final operation = auth.authenticate(context, () => write.future);
    await tester.pump();
    sessions.add('new-provider');
    await tester.pump();
    expect(auth.isSignedIn, isFalse);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // A hardware Back must not dismiss the in-flight authentication dialog.
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    write.complete();
    await operation;
    await tester.pumpAndSettle();
    expect(find.text('Signed-in home'), findsOneWidget);
    expect(
        find.byType(ProviderRegisterPage, skipOffstage: false), findsNothing);
    expect(find.byType(LoginPage, skipOffstage: false), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(auth.navigatorKey.currentState!.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Logout clears protected screens and dialogs; Back cannot reopen them',
      (tester) async {
    await mount(tester, userId: 'user-a');
    final navigator = auth.navigatorKey.currentState!;
    unawaited(navigator.push<void>(MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: Text('Protected detail')),
    )));
    await tester.pumpAndSettle();
    unawaited(showDialog<void>(
      context: tester.element(find.text('Protected detail')),
      builder: (_) => const AlertDialog(title: Text('Protected dialog')),
    ));
    await tester.pumpAndSettle();

    sessions.add(null);
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Protected detail', skipOffstage: false), findsNothing);
    expect(find.text('Protected dialog', skipOffstage: false), findsNothing);
    expect(auth.navigatorKey.currentState!.canPop(), isFalse);
    expect(await auth.navigatorKey.currentState!.maybePop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Failed authentication removes only its loader and keeps the form',
      (tester) async {
    await mount(tester);
    final context = tester.element(find.byType(LoginPage));
    await auth.authenticate(context, () async {
      throw FirebaseAuthException(code: 'invalid-credential');
    });
    await tester.pumpAndSettle();
    expect(find.text('invalid-credential'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    auth.navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(auth.navigatorKey.currentState!.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A late authentication completion cannot pop the new session',
      (tester) async {
    await mount(tester, userId: 'user-a');
    final pending = Completer<void>();
    final operation = auth.authenticate(
        tester.element(find.text('Signed-in home')), () => pending.future);
    await tester.pump();
    sessions.add(null);
    await tester.pumpAndSettle();
    pending.complete();
    await operation;
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(auth.navigatorKey.currentState!.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Protected entry points reject signed-out navigation',
      (tester) async {
    await mount(tester);
    final context = tester.element(find.byType(LoginPage));
    await AppRoutes.openProfile(context);
    await AppRoutes.openMessages(context);
    await AppRoutes.openCreatePost(context);
    await AppRoutes.openPost(context, postId: 'post-1');
    await AppRoutes.openChat(context,
        receiverUserID: 'receiver-1',
        receiverUserEmail: 'receiver@example.com');
    await AppRoutes.openEditProfile(context, userData: null);
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(auth.navigatorKey.currentState!.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Missing route data shows an error without opening a broken destination',
      (tester) async {
    await mount(tester, userId: 'user-a');
    final context = tester.element(find.text('Signed-in home'));
    await AppRoutes.openPost(context, postId: '');
    await tester.pumpAndSettle();
    expect(find.text('This post is unavailable.'), findsOneWidget);
    auth.navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    await AppRoutes.openChat(context,
        receiverUserID: '', receiverUserEmail: 'receiver@example.com');
    await tester.pumpAndSettle();
    expect(find.text('This conversation is unavailable.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Typed destinations receive their IDs and profile data',
      (tester) async {
    await mount(tester, userId: 'user-a');
    final context = tester.element(find.text('Signed-in home'));
    final navigator = auth.navigatorKey.currentState!;

    // Inspect the route before mounting its Firebase-backed screen.
    final postResult = AppRoutes.openPost(context, postId: 'post with spaces');
    final postRoute = observer.lastPushed! as MaterialPageRoute<void>;
    expect(postRoute.settings.name, '/posts/post%20with%20spaces');
    expect((postRoute.builder(context) as OpenedPostPage).postId,
        'post with spaces');
    navigator.removeRoute(postRoute);
    await postResult;
    await tester.pumpAndSettle();

    final chatResult = AppRoutes.openChat(context,
        receiverUserID: 'receiver-1',
        receiverUserEmail: 'receiver@example.com');
    final chatRoute = observer.lastPushed! as MaterialPageRoute<void>;
    final chat = chatRoute.builder(context) as ChatPage;
    expect(chat.receiverUserID, 'receiver-1');
    expect(chat.receiverUserEmail, 'receiver@example.com');
    navigator.removeRoute(chatRoute);
    await chatResult;
    await tester.pumpAndSettle();

    final editResult = AppRoutes.openEditProfile(context,
        userData: {'username': 'Existing name', 'email': 'user@example.com'});
    final editRoute = observer.lastPushed! as MaterialPageRoute<void>;
    final edit = editRoute.builder(context) as EditProfilePage;
    expect(edit.userData?['username'], 'Existing name');
    expect(edit.userData?['email'], 'user@example.com');
    navigator.removeRoute(editRoute);
    await editResult;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Detail Back returns to its caller without replacing Home',
      (tester) async {
    await mount(tester, userId: 'user-a');
    final navigator = auth.navigatorKey.currentState!;
    unawaited(navigator.push<void>(MaterialPageRoute<void>(
      builder: (_) => Scaffold(appBar: AppBar(), body: const Text('Detail')),
    )));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Signed-in home'), findsOneWidget);
    expect(navigator.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('An authentication stream error removes protected content',
      (tester) async {
    await mount(tester, userId: 'user-a');
    sessions.addError(StateError('session unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('Signed-in home'), findsNothing);
    expect(find.text('Unable to load your session. Please restart the app.'),
        findsOneWidget);
    expect(auth.isSignedIn, isFalse);
    expect(tester.takeException(), isNull);
  });
}
