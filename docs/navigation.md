Routing review and implementation

The application uses ten destination screens across auth, home, posts, chat, and profile. Before this change, two additional widgets (AuthPage and LoginOrRegister) handled authentication and toggled the login/registration UI.

Current-project findings

| Area | Finding before implementation |
| --- | --- |
| Routing | MaterialApp.routes contained four named routes; other screens constructed MaterialPageRoute directly. Drawer route strings bypassed the existing constants. |
| Authentication | AuthPage changed its root child on authStateChanges. It did not remove routes or dialogs pushed above that child. |
| Login and registration | Login and customer registration relied on the auth gate. Provider registration also replaced its own route with another Home, allowing duplicate Home routes. Its Login Here callback was empty. |
| Loading dialogs | Authentication callbacks popped whichever route was on top. A dismissible dialog or a session change could make that the wrong route. |
| Registration completion | User-document writes were not awaited, so Home could query the document before it existed. |
| Splash/onboarding | No Dart onboarding or splash flow exists. Native launch screens are platform boot UI. The old auth gate did not distinguish session restoration from signed-out state. |
| Bottom navigation | Home uses local selectedIndex and AnimatedSwitcher for Providers and Ask for Service feeds. There are no independent tab navigation stacks. |
| Detail navigation | Home opens post details; a post or the Messages screen opens Chat. Profile opens Edit Profile. These are ordinary pushed screens. |
| Arguments | Post details require a post ID. Chat requires a receiver UID and email. Edit Profile accepts the existing nullable user-data map. |
| Deep links | No app-link/universal-link configuration or route-parameter parser was found. Firebase web configuration alone is not a requirement for browser URL routing. |
| State management | Screens use setState, StreamBuilder, and FutureBuilder. ChatService extends ChangeNotifier, but provider was not wired into the app tree. |
| Growth | Additional feature screens can use the same typed entry points. Independent tab histories, shareable URLs, or notification deep links would justify reassessing the router. |

Decision

Use one Flutter Navigator with centralized typed navigation methods and MaterialPageRoute. Replace the named-route table rather than extending string arguments and casts. Use the already installed provider package only to expose the small AuthNavigation coordinator. Existing Firebase service calls and screen state remain in their current features.

Neither ShellRoute nor StatefulShellRoute is needed: the two Home feeds are local content choices. A custom RouterDelegate would add unnecessary work. go_router becomes useful if URL routing or independent navigator branches become actual requirements. Flutter's guidance supports Navigator for simple navigation and a Router package for advanced links or multiple navigators:
https://docs.flutter.dev/ui/navigation

Architecture

```text
lib/
  app/app.dart                  Provider ownership and the single MaterialApp
  routes/
    app_routes.dart             Route identifiers, typed arguments, destination builders
    auth_navigation.dart        Session subscription and complete stack resets
  features/                     Existing screens, services, and widgets
```

No separate route_names.dart, route_paths.dart, code generation, nested navigator, or new dependency is required. The identifiers below are RouteSettings names for in-app navigation, not registered web URLs.

Final route map and behavior

| Identifier | Destination / purpose | Navigation behavior |
| --- | --- | --- |
| /loading | Restore the initial Firebase session | Temporary root; replaced when the first auth event arrives |
| /auth-error | Session stream failure | Protected stack is removed; a later valid event can recover |
| /login | Login | Signed-out root |
| /register | Customer registration | Push from Login; Back returns to Login |
| /register/provider | Provider registration | Push from Register; Back returns to Register |
| /home | Home and its two feeds | Signed-in root |
| /profile | Current user's profile | Push from Home; Back returns to Home |
| /profile/edit | Edit Profile | Push from Profile; save/Back pops to Profile, which refreshes |
| /messages | User/message list | Push from Home; Back returns to Home |
| /messages/:receiverId | Chat | Push from Messages or post details; Back returns to the actual caller |
| /posts/create | Create post | Push from Home; successful submission/Back pops to Home |
| /posts/:postId | Post details | Push from either Home feed; Back preserves the existing Home state |

Login Here from either registration screen pops to the existing Login root. Successful login or either registration replaces the Navigator, leaving exactly one Home root. Logout and user-account changes also replace the Navigator, removing every previous screen and dialog. Back cannot reopen the previous session.

The authentication coordinator defers the signed-in transition until the existing registration document write completes. Its loading dialog cannot be dismissed while the request is running, and completion removes that exact dialog rather than an arbitrary top route. Authentication/write errors are shown on the current session's navigator. A failed document write does not roll back the Firebase account; adding an account-repair workflow would be a separate business change.

Protected navigation methods reject signed-out callers. Required post/chat identifiers are validated before pushing, and arguments are passed through Dart parameters rather than unchecked RouteSettings casts. Route identifiers encode dynamic IDs; the raw ID is passed unchanged to the screen. The duplicate-push guard rejects callbacks from covered routes. Bottom feed switching still uses Home's existing local state.

Changed files

Created:
- lib/routes/auth_navigation.dart
- docs/navigation.md

Modified:
- lib/routes/app_routes.dart
- lib/app/app.dart
- lib/features/auth/screens/login_screen.dart
- lib/features/auth/screens/register_screen.dart
- lib/features/auth/screens/provider_register_screen.dart
- lib/features/home/widgets/my_drawer.dart
- lib/features/chat/screens/users_screen.dart
- lib/features/posts/widgets/ask_for_service_post_list.dart
- lib/features/posts/widgets/providers_post_list.dart
- lib/features/posts/screens/open_post_screen.dart
- lib/features/posts/screens/create_post_screen.dart
- lib/features/profile/screens/profile_screen.dart
- lib/features/profile/screens/edit_profile_screen.dart
- test/widget_test.dart

Removed after replacing their behavior:
- lib/features/auth/screens/auth_screen.dart
- lib/features/auth/screens/login_or_register_screen.dart

Validation

`flutter test --no-pub`: all 11 tests passed. `flutter analyze --no-pub`: no errors; 22 pre-existing findings remain (2 warnings and 20 informational lints). There are no remaining routing/import errors or lints in the new routing files.

Automated navigation coverage uses real guest screens and a stand-in for Home's Firebase-backed content. It covers initial restoration, repeated/account-change auth events, registration Back behavior, the provider Login link, deferred registration completion, a non-dismissible loader, full logout cleanup, failed authentication, late request completion after logout, protected-entry rejection, invalid arguments, typed destination argument delivery, detail Back, and stream errors.

The source-level flow review also covers drawer closing before navigation, both post-list entry points, post-to-chat and messages-to-chat argument delivery, edit-profile return/refresh, create-post return, and logout error handling. Live Firebase login, account creation, and physical Android/iOS gestures were not exercised.
