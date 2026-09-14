import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:service_finder_application/features/home/widgets/home_drawer_tile.dart';
import 'package:service_finder_application/features/profile/services/profile_service.dart';
import 'package:service_finder_application/features/profile/models/user_profile.dart';
import 'package:service_finder_application/features/auth/services/auth_service.dart';
import 'package:service_finder_application/routes/app_routes.dart';
import 'package:service_finder_application/core/utils/helper_functions.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late final Future<UserProfile?> _profile =
      ProfileService().getCurrentProfile();

  void _open(Future<void> Function(BuildContext) destination) {
    final pageContext = Scaffold.of(context).context;
    Navigator.pop(context);
    destination(pageContext);
  }

  Future<void> _logout() async {
    final pageContext = Scaffold.of(context).context;
    Navigator.pop(context);
    try {
      await AuthService().signOut();
    } on FirebaseAuthException catch (error) {
      if (pageContext.mounted) displayMessageToUser(error.code, pageContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28))),
      child: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 20),
            child: Row(children: [
              const Icon(Icons.home_repair_service_outlined,
                  color: Color(0xFF087F88)),
              const SizedBox(width: 10),
              const Expanded(
                  child: Text('Service Finder',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700))),
              IconButton(
                  tooltip: 'Close menu',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded)),
            ]),
          )),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FutureBuilder<UserProfile?>(
              future: _profile,
              builder: (context, snapshot) {
                final user = snapshot.data;
                final name = user?.username?.trim();
                final email = user?.email ??
                    FirebaseAuth.instance.currentUser?.email ??
                    '';
                final image = user?.profileImage;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF129BA8), Color(0xFF087F88)])),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: 58,
                            height: 58,
                            child: ClipOval(
                                child: image == null || image.isEmpty
                                    ? _avatar()
                                    : Image.network(image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _avatar()))),
                        const SizedBox(height: 14),
                        Text(
                            name == null || name.isEmpty
                                ? 'Your account'
                                : name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(email,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: LinearProgressIndicator(
                                  color: Colors.white,
                                  backgroundColor: Colors.white24)),
                        if (snapshot.hasError)
                          const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                  'Profile details are unavailable right now.',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12))),
                      ]),
                );
              },
            ),
          )),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            sliver: SliverList.list(children: [
              Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text('EXPLORE',
                      style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant))),
              HomeDrawerTile(
                  icon: Icons.grid_view_rounded,
                  title: 'Home',
                  selected: true,
                  onTap: () => Navigator.pop(context)),
              HomeDrawerTile(
                  icon: Icons.person_outline_rounded,
                  title: 'My profile',
                  onTap: () => _open(AppRoutes.openProfile)),
              HomeDrawerTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Messages',
                  onTap: () => _open(AppRoutes.openMessages)),
              const SizedBox(height: 16),
              FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF087F88),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  onPressed: () => _open(AppRoutes.openCreatePost),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create a post')),
            ]),
          ),
          SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(),
                        HomeDrawerTile(
                            icon: Icons.logout_rounded,
                            title: 'Log out',
                            destructive: true,
                            onTap: _logout),
                      ]))),
        ]),
      ),
    );
  }

  Widget _avatar() => const ColoredBox(
      color: Color(0xFFE2F5F5),
      child: Icon(Icons.person_outline_rounded,
          color: Color(0xFF087F88), size: 30));
}
