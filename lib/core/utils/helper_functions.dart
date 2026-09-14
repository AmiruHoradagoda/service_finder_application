import 'package:flutter/material.dart';
import 'package:service_finder_application/shared/widgets/app_message_dialog.dart';

export 'package:service_finder_application/shared/widgets/app_message_dialog.dart'
    show MessageType;

void displayMessageToUser(
  String message,
  BuildContext context, {
  MessageType type = MessageType.error,
  String? title,
}) {
  if (!context.mounted) return;
  final (suggestedTitle, description) = _friendlyMessage(message, type);
  showDialog(
    context: context,
    builder: (context) => AppMessageDialog(
      title: title ?? suggestedTitle,
      message: description,
      type: type,
    ),
  );
}

(String, String) _friendlyMessage(String message, MessageType type) {
  final code =
      message.trim().toLowerCase().replaceAll('auth/', '').replaceAll('_', '-');
  return switch (code) {
    'invalid-credential' ||
    'invalid-login-credentials' ||
    'wrong-password' ||
    'user-not-found' =>
      (
        'Unable to sign in',
        'The email or password is incorrect. Check your details and try again.'
      ),
    'invalid-email' => (
        'Check your email',
        'Please enter a valid email address.'
      ),
    'email-already-in-use' => (
        'Account already exists',
        'This email is already linked to an account. Sign in with it, or use a different email.'
      ),
    'weak-password' => (
        'Choose a stronger password',
        'Use a password with at least 6 characters.'
      ),
    'too-many-requests' => (
        'Please wait a moment',
        'There have been too many attempts. Wait a little before trying again.'
      ),
    'network-request-failed' => (
        'Connection problem',
        'Check your internet connection and try again.'
      ),
    'user-disabled' => (
        'Account unavailable',
        'This account has been disabled. Contact support for help.'
      ),
    'operation-not-allowed' || 'password-login-disabled' => (
        'Sign-in unavailable',
        'Email and password sign-in is currently unavailable. Please contact the app administrator.'
      ),
    'requires-recent-login' => (
        'Sign in again',
        'For your security, sign out and sign in again before making this change.'
      ),
    'permission-denied' => (
        'Action not allowed',
        'Your account does not have permission to complete this action.'
      ),
    'unavailable' => (
        'Service unavailable',
        'We couldn’t connect to the service. Please try again shortly.'
      ),
    "passwords don't match!" => (
        'Passwords don’t match',
        'Enter the same password in both fields, then try again.'
      ),
    'you must agree to the terms and conditions' => (
        'One more step',
        'Please agree to the terms and conditions to create your provider account.'
      ),
    _ => (
        switch (type) {
          MessageType.error => 'Something went wrong',
          MessageType.warning => 'Please check this',
          MessageType.info => 'Good to know',
        },
        RegExp(r'^[a-z]+(?:-[a-z]+)+$').hasMatch(code)
            ? 'We couldn’t complete your request. Please try again.'
            : message,
      ),
  };
}
