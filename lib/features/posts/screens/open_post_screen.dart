import 'package:flutter/material.dart';
import 'package:service_finder_application/features/posts/services/post_service.dart';
import 'package:service_finder_application/routes/app_routes.dart';

class OpenedPostPage extends StatelessWidget {
  final String postId;

  const OpenedPostPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final PostService service = PostService();
    final theme = Theme.of(context);

    return FutureBuilder(
      future: service.getPostById(postId),
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

        if (!snapshot.hasData) {
          return Center(
            child: Text(
              "Post not found",
              style: theme.textTheme.bodyLarge,
            ),
          );
        }

        final post = snapshot.data!;
        final postMessage = post.message;
        final description = post.description;
        final address = post.address;
        final mobile1 = post.mobile1;
        final mobile2 = post.mobile2;
        final username = post.username ?? '';
        final userEmail = post.userEmail ?? '';
        final userID = post.userId;
        final imageUrls = post.imageUrls;
        final ask = post.isAsk ?? false;
        final whatsappLink = post.whatsappLink;
        final facebookLink = post.facebookLink;
        final websiteLink = post.websiteLink;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Post Details"),
            backgroundColor: Theme.of(context).colorScheme.primary,
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
                    (whatsappLink != null ||
                        facebookLink != null ||
                        websiteLink != null))
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
                          if (whatsappLink != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("WhatsApp: "),
                                Text(
                                  whatsappLink,
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
                          if (facebookLink != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Facebook: "),
                                Text(
                                  facebookLink,
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
                          if (websiteLink != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Website: "),
                                Text(
                                  websiteLink,
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
              AppRoutes.openChat(
                context,
                receiverUserEmail: userEmail,
                receiverUserID: userID,
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.message),
          ),
        );
      },
    );
  }
}
