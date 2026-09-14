import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/core/utils/helper_functions.dart';

/// Owns only navigation session state, not Firebase authentication or user data.
class AuthNavigation extends ChangeNotifier {
  AuthNavigation(Stream<String?> sessions) {
    _subscription = sessions.listen((userId) {
      _receivedSession = true;
      _latestUserId = userId;
      _latestError = null;
      // Sign-out clears protected routes even during an outstanding request.
      if (!_authInProgress || userId == null) _publishSession();
    }, onError: (Object error) {
      _latestError = error;
      _publishSession();
    });
  }

  late final StreamSubscription<String?> _subscription;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _receivedSession = false;
  bool _authInProgress = false;
  bool _disposed = false;
  String? _latestUserId;
  Object? _latestError;
  String? _userId;
  bool isLoading = true;
  Object? streamError;

  bool get isSignedIn => !isLoading && streamError == null && _userId != null;

  void _publishSession() {
    if (_disposed) return;
    final loading = !_receivedSession && _latestError == null;
    if (isLoading == loading &&
        _userId == _latestUserId &&
        streamError == _latestError) {
      return;
    }
    isLoading = loading;
    _userId = _latestUserId;
    streamError = _latestError;
    // A new Navigator removes all old screens and dialogs on session changes.
    navigatorKey = GlobalKey<NavigatorState>();
    notifyListeners();
  }

  /// Waits for the complete operation before changing stacks. The loading dialog
  /// is removed by identity, so completing a request cannot pop another screen.
  Future<void> authenticate(
      BuildContext context, Future<void> Function() operation) async {
    if (_authInProgress) return;
    _authInProgress = true;
    final navigator = Navigator.of(context);
    final dialog = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    unawaited(navigator.push<void>(dialog));
    Object? failure;
    try {
      await operation();
    } catch (error) {
      failure = error;
    } finally {
      if (navigator.mounted && dialog.isActive) navigator.removeRoute(dialog);
      _authInProgress = false;
      _publishSession();
    }
    if (failure != null && !_disposed) {
      final message =
          failure is FirebaseException ? failure.code : failure.toString();
      // A write can fail after Firebase signs in; use the resulting session's
      // Navigator to surface the error instead of a disposed form context.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = navigatorKey.currentState?.overlay?.context;
        if (!_disposed && context != null && context.mounted) {
          displayMessageToUser(message, context);
        }
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
