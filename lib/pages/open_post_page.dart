import 'package:flutter/material.dart';
import 'package:service_finder_application/database/firestore.dart';
import 'package:service_finder_application/pages/chat_page.dart';

class OpenedPostPage extends StatelessWidget {
  final String postId;

  const OpenedPostPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final FirestoreDatabase database = FirestoreDatabase();
    final theme = Theme.of(context);

    return FutureBuilder(
      future: database.getPostById(postId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading post details",
              style: theme.textTheme.bodyLarge,
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text(
              "Post not found",
              style: theme.textTheme.bodyLarge,
            ),
          );
        }

        final postData = snapshot.data!.data() as Map<String, dynamic>;
        String postMessage = postData['PostMessage'] ?? '';
        String description = postData['Description'] ?? '';
        String address = postData['Address'] ?? '';
        String mobile1 = postData['Mobile1'] ?? '';
        String? mobile2 = postData['Mobile2'];
        String username = postData['username'] ?? '';
        String userEmail = postData['UserEmail'] ??
            ''; // Assuming the email is stored in the post
        String userID = postData['UserID'] ??
            ''; // Assuming the user ID is stored in the post
        List<dynamic> imageUrls = postData['ImageUrls'] ?? [];
        bool ask = postData['ask'] ?? false;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Post Details"),
            backgroundColor: Colors.teal,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          postMessage,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "by $username",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Description Section
                Text(
                  description,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                // Contact Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    // Center widget added
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Center the text inside the column
                      children: [
                        Text(
                          "Contact",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("Address: $address"),
                        const SizedBox(height: 8),
                        Text("Mobile No: $mobile1"),
                        if (mobile2 != null) ...[
                          const SizedBox(height: 8),
                          Text("Mobile No: $mobile2"),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Social Links Section - Visible only if `ask` is false
                if (!ask &&
                    (postData['WhatsappLink'] != null ||
                        postData['FacebookLink'] != null ||
                        postData['WebsiteLink'] != null))
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Social Links",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (postData['WhatsappLink'] != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("WhatsApp: "),
                                Text(
                                  postData['WhatsappLink'],
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                    decorationThickness: 2.0,
                                  ),
                                ),
                              ],
                            )
                          ],
                          if (postData['FacebookLink'] != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Facebook: "),
                                Text(
                                  postData['FacebookLink'],
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                    decorationThickness: 2.0,
                                  ),
                                ),
                              ],
                            )
                          ],
                          if (postData['WebsiteLink'] != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Website: "),
                                Text(
                                  postData['WebsiteLink'],
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                    decorationThickness: 2.0,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Image Gallery
                if (imageUrls.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrls[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          // Floating Action Button to open chat
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverUserEmail: userEmail,
                    receiverUserID: userID,
                  ),
                ),
              );
            },
            child: const Icon(Icons.message),
            backgroundColor: Colors.teal,
          ),
        );
      },
    );
  }
}
