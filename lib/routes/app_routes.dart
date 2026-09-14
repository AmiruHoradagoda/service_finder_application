import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_finder_application/core/utils/helper_functions.dart';
import 'package:service_finder_application/features/auth/screens/login_screen.dart';
import 'package:service_finder_application/features/auth/screens/register_screen.dart';
import 'package:service_finder_application/features/auth/screens/provider_register_screen.dart';
import 'package:service_finder_application/features/home/screens/home_screen.dart';
import 'package:service_finder_application/features/profile/screens/profile_screen.dart';
import 'package:service_finder_application/features/profile/screens/edit_profile_screen.dart';
import 'package:service_finder_application/features/chat/screens/users_screen.dart';
import 'package:service_finder_application/features/chat/screens/chat_screen.dart';
import 'package:service_finder_application/features/posts/screens/create_post_screen.dart';
import 'package:service_finder_application/features/posts/screens/open_post_screen.dart';
import 'package:service_finder_application/routes/auth_navigation.dart';

/// Typed navigation entry points. Paths identify routes; they are not web URLs.
class AppRoutes {
  const AppRoutes._();

  static const loading = '/loading';
  static const authError = '/auth-error';
  static const login = '/login';
  static const register = '/register';
  static const providerRegister = '/register/provider';
  static const home = '/home';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const messages = '/messages';
  static const createPost = '/posts/create';
  static const posts = '/posts';

  static Route<void> initialRoute(AuthNavigation auth) {
    if (auth.isLoading) {
      return _route(
          loading,
          (_) => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ));
    }
    if (auth.streamError != null) {
      return _route(
          authError,
          (_) => const Scaffold(
                body: Center(
                    child: Text(
                        'Unable to load your session. Please restart the app.')),
              ));
    }
    return auth.isSignedIn
        ? _route(home, (_) => HomePage())
        : _route(
            login,
            (context) => LoginPage(
                  onTap: () => openRegister(context),
                ));
  }

  static Future<void> openRegister(BuildContext context) => _push(
        context,
        register,
        (context) => RegisterPage(onTap: () => returnToLogin(context)),
        requiresAuth: false,
      );

  static Future<void> openProviderRegistration(BuildContext context) => _push(
        context,
        providerRegister,
        (context) =>
            ProviderRegisterPage(onLogin: () => returnToLogin(context)),
        requiresAuth: false,
      );

  static void returnToLogin(BuildContext context) {
    if (!context.read<AuthNavigation>().isSignedIn) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  static Future<void> openProfile(BuildContext context) =>
      _push(context, profile, (_) => const ProfilePage());

  static Future<void> openEditProfile(
    BuildContext context, {
    required Map<String, dynamic>? userData,
  }) =>
      _push(
          context,
          editProfile,
          (_) => EditProfilePage(
                userData: userData == null
                    ? null
                    : Map<String, dynamic>.unmodifiable(userData),
              ));

  static Future<void> openMessages(BuildContext context) =>
      _push(context, messages, (_) => const UsersPage());

  static Future<void> openCreatePost(BuildContext context) =>
      _push(context, createPost, (_) => const PostPage());

  static Future<void> openPost(BuildContext context, {required String postId}) {
    if (postId.trim().isEmpty) {
      displayMessageToUser('This post is unavailable.', context);
      return Future<void>.value();
    }
    return _push(context, '$posts/${Uri.encodeComponent(postId)}',
        (_) => OpenedPostPage(postId: postId));
  }

  static Future<void> openChat(
    BuildContext context, {
    required String receiverUserID,
    required String receiverUserEmail,
  }) {
    if (receiverUserID.trim().isEmpty || receiverUserEmail.trim().isEmpty) {
      displayMessageToUser('This conversation is unavailable.', context);
      return Future<void>.value();
    }
    return _push(
        context,
        '$messages/${Uri.encodeComponent(receiverUserID)}',
        (_) => ChatPage(
              receiverUserID: receiverUserID,
              receiverUserEmail: receiverUserEmail,
            ));
  }

  static MaterialPageRoute<void> _route(String name, WidgetBuilder builder) =>
      MaterialPageRoute<void>(
          settings: RouteSettings(name: name), builder: builder);

  static Future<void> _push(
    BuildContext context,
    String name,
    WidgetBuilder builder, {
    bool requiresAuth = true,
  }) async {
    final auth = context.read<AuthNavigation>();
    if (auth.isLoading ||
        auth.streamError != null ||
        auth.isSignedIn != requiresAuth ||
        ModalRoute.of(context)?.isCurrent != true ||
        ModalRoute.of(context)?.settings.name == name) {
      return;
    }
    await Navigator.of(context).push<void>(_route(name, builder));
  }
}
