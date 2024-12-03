import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/pages/edit_profile_page.dart'; // Import for edit profile

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  // Fetch user posts
  Future<QuerySnapshot<Map<String, dynamic>>> getUserPosts() async {
    return await FirebaseFirestore.instance
        .collection("Posts")
        .where('UserEmail', isEqualTo: currentUser!.email)
        .get();
  }

  // Function to delete post
  void _deletePost(BuildContext context, String postId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection("Posts")
                      .doc(postId)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Post deleted successfully!")),
                  );
                  setState(() {});
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error deleting post: $e")),
                  );
                }
              },
              child: Text("Delete", style: TextStyle(color: Colors.grey[700])),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        // User details future
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            return SafeArea(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Image Section
                    GestureDetector(
                      onTap: () {
                        // You can add logic to update the profile image
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          user?['profileImage'] ??
                              'https://www.pngkey.com/png/full/115-1150152_default-profile-picture-avatar-png-green.png',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      user?['username'] ?? 'User Name',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color, // Theme-based text color
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?['email'] ?? 'Email Address',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                                userData: user), // Edit Profile Screen
                          ),
                        );
                      },
                      child: const Text("Edit Profile"),
                    ),
                    const SizedBox(height: 30),
                    // Posts Section
                    const Text("My Posts",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const Divider(thickness: 1),
                    FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      // Fetch user posts
                      future: getUserPosts(),
                      builder: (context, postsSnapshot) {
                        if (postsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (postsSnapshot.hasError) {
                          return Text("Error: ${postsSnapshot.error}");
                        } else if (postsSnapshot.hasData) {
                          final posts = postsSnapshot.data!.docs;
                          return Expanded(
                            child: ListView.builder(
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                final post = posts[index];
                                final data = post.data();
                                String postId = data['post_ID'];
                                String message = data['PostMessage'];
                                String? username = data['username'];
                                List<dynamic> imageUrls =
                                    data['ImageUrls'] ?? [];
                                String? thumbnailUrl =
                                    imageUrls.isNotEmpty ? imageUrls[0] : null;

                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to post details
                                  },
                                  child: ListTile(
                                    title: Text(message),
                                    subtitle: Text(username ?? 'Unknown user'),
                                    leading: thumbnailUrl != null
                                        ? Image.network(thumbnailUrl)
                                        : null,
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deletePost(context, postId),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return const Center(child: Text("No posts found"));
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text("No user data found"));
          }
        },
      ),
    );
  }
}
