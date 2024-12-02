import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/pages/create_post_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // Function to fetch current user data
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser?.email)
        .get();
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blue[50], // Light blue background for the drawer
      child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            var user = snapshot.data!.data();
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    // Profile section at the top with circular avatar, name, and email
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors
                            .blue[700], // Blue background for profile section
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Circular Avatar with Shadow
                          const CircleAvatar(
                            radius: 45,
                            backgroundImage: NetworkImage(
                                'https://www.pngkey.com/png/full/115-1150152_default-profile-picture-avatar-png-green.png'), // Replace with user's avatar URL
                            backgroundColor: Colors.transparent,
                          ),
                          const SizedBox(
                              width: 15), // Spacing between avatar and text
                          // User Name and Email
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?['username'] ?? 'User Name',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // White text for name
                                ),
                              ),
                              Text(
                                user?['email'] ?? 'Email Address',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color:
                                      Colors.white70, // Light white for email
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 45),
                    // Drawer items
                    _buildListTile(
                      context,
                      icon: Icons.home,
                      title: 'H O M E',
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildListTile(
                      context,
                      icon: Icons.person,
                      title: 'P R O F I L E',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile_page');
                      },
                    ),
                    _buildListTile(
                      context,
                      icon: Icons.group,
                      title: 'U S E R S',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/users_page');
                      },
                    ),
                    _buildListTile(
                      context,
                      icon: Icons.add_circle_outline,
                      title: 'C R E A T E  P O S T',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PostPage()),
                        );
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, bottom: 25),
                  child: _buildListTile(
                    context,
                    icon: Icons.logout,
                    title: 'L O G  O U T',
                    onTap: () {
                      Navigator.pop(context);
                      logout();
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text("No user data found"));
          }
        },
      ),
    );
  }

  // Helper method to create the ListTiles
  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue[800], // Icon color matching the blue theme
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.blue[800], // Text color matching the blue theme
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
