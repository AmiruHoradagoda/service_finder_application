import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/components/my_list_tile.dart';
import 'package:service_finder_application/pages/open_post_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // current logged-in user
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  // future to fetch posts created by the user
  Future<QuerySnapshot<Map<String, dynamic>>> getUserPosts() async {
    return await FirebaseFirestore.instance
        .collection("Posts")
        .where('UserEmail', isEqualTo: currentUser!.email)
        .get();
  }

  // Function to delete a post
  void _deletePost(BuildContext context, String postId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Delete the post
                  await FirebaseFirestore.instance
                      .collection("Posts")
                      .doc(postId)
                      .delete();

                  // Show confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Post deleted successfully!")),
                  );

                  // Refresh the posts list after deletion
                  setState(
                      () {}); // Triggers a rebuild of the page to show the updated list of posts
                  Navigator.pop(context); // Close the confirmation dialog
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error deleting post: $e")),
                  );
                }
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to update password
  void _changePassword(BuildContext context) async {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmNewPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmNewPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (newPasswordController.text !=
                    confirmNewPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwords do not match!")),
                  );
                } else {
                  try {
                    final cred = EmailAuthProvider.credential(
                        email: currentUser!.email!,
                        password: currentPasswordController.text);

                    // Re-authenticate user
                    await currentUser!.reauthenticateWithCredential(cred);

                    // Update password
                    await currentUser!
                        .updatePassword(newPasswordController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Password changed successfully!")),
                    );
                    Navigator.pop(context);
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text(e.message ?? "Error updating password")),
                    );
                  }
                }
              },
              child: Text(
                'Change',
                style: TextStyle(color: Colors.grey[700]),
              ),
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
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
                    const Padding(
                      padding: EdgeInsets.only(left: 10, top: 10),
                      child: Row(
                        children: [BackButton()],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: const Icon(
                        Icons.person,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      user!['username'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      user['email'],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => _changePassword(context),
                      child: Text(
                        "Change Password",
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "My Posts",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                            width: 10), // Optional: space between text and line
                        Expanded(
                          child: Divider(
                            thickness: 1, // Line thickness
                            color: Colors.grey, // Line color
                          ),
                        ),
                      ],
                    ),

                    // Display posts
                    FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                                final data = post.data(); // Cast to Map

                                String message = data['PostMessage'];
                                String? username = data[
                                    'username']; // Get username instead of email
                                List<dynamic> imageUrls =
                                    data['ImageUrls'] ?? [];
                                String? thumbnailUrl =
                                    imageUrls.isNotEmpty ? imageUrls[0] : null;
                                String postId = data[
                                    'post_ID']; // Fetch post_ID from the post data

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OpenedPostPage(
                                          postId:
                                              postId, // Pass post_ID to OpenedPostPage
                                        ),
                                      ),
                                    );
                                  },
                                  child: MyListTile(
                                    title: message,
                                    subtitle: username ?? 'Unknown user',
                                    leadingImage: thumbnailUrl,
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        _deletePost(
                                            context, postId); // Delete post
                                      },
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
