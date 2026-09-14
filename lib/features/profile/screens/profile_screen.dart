import 'package:service_finder_application/features/profile/widgets/profile_posts_list.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/features/posts/services/post_service.dart';
import 'package:service_finder_application/features/profile/services/profile_service.dart';
import 'package:service_finder_application/features/profile/models/user_profile.dart';
import 'package:service_finder_application/routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profiles = ProfileService();
  final PostService _posts = PostService();

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
                  await _posts.deletePost(postId);
                  if (!mounted || !context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Post deleted successfully!")),
                  );
                  setState(() {});
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
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
      body: FutureBuilder<UserProfile?>(
        // User details future
        future: _profiles.getCurrentProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            String greeting = user.isProvider
                ? 'Welcome, Service Provider!'
                : 'Welcome, Valued Customer!';
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Profile Image Section with shadow and rounded borders
                    GestureDetector(
                      onTap: () {
                        // Add logic to update the profile image if necessary
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          user.profileImage ??
                              'https://www.pngkey.com/png/full/115-1150152_default-profile-picture-avatar-png-green.png',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      greeting, // Personalized greeting
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color, // Theme-based text color
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.username ?? 'User Name',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email ?? 'Email Address',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    // Bio Section
                    if (user.bio != null)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Bio",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                user.bio ?? 'No bio available',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Phone Number Section
                    if (user.phone != null)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.phone,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 10),
                              Text(user.phone ?? 'Phone Number not set'),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Address Section
                    if (user.address != null)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 10),
                              Text(user.address ?? 'Address not set'),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    // Edit Profile Button with more width
                    SizedBox(
                      width:
                          double.infinity, // Make the button take up full width
                      child: ElevatedButton(
                        onPressed: () async {
                          await AppRoutes.openEditProfile(context,
                              profile: user);
                          if (mounted) setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text("Edit Profile",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Posts Section with better title styling
                    const Text("My Posts",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const Divider(thickness: 1),
                    ProfilePostsList(
                        posts: _posts.getCurrentUserPosts(),
                        onDelete: (postId) => _deletePost(context, postId)),
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
