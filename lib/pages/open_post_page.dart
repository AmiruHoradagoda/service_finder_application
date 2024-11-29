import 'package:flutter/material.dart';
import 'package:service_finder_application/database/firestore.dart';

class OpenedPostPage extends StatelessWidget {
  final String postId;

  const OpenedPostPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final FirestoreDatabase database = FirestoreDatabase();

    return FutureBuilder(
      future: database.getPostById(postId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text("Error loading post details"),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text("Post not found"),
          );
        }

        // Fetching post data
        final postData = snapshot.data!.data() as Map<String, dynamic>;
        String postMessage = postData['PostMessage'] ?? '';
        String description = postData['Description'] ?? '';
        String address = postData['Address'] ?? '';
        String mobile1 = postData['Mobile1'] ?? '';
        String? mobile2 = postData['Mobile2'];
        String username = postData['username'] ?? '';
        String? whatsappLink = postData['WhatsappLink'];
        String? facebookLink = postData['FacebookLink'];
        String? websiteLink = postData['WebsiteLink'];
        bool isAsk = postData['ask'] ?? false;
        List<dynamic> imageUrls = postData['ImageUrls'] ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text("Post Details"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the images
                if (imageUrls.isNotEmpty) ...[
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.network(imageUrls[index]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Post Message
                Text(
                  postMessage,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  "Description: $description",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                // Address
                Text(
                  "Address: $address",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                // Mobile Numbers
                Text(
                  "Mobile 1: $mobile1",
                  style: const TextStyle(fontSize: 16),
                ),
                if (mobile2 != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Mobile 2: $mobile2",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
                const SizedBox(height: 8),
                // User ID
                Text(
                  "User Name: $username",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                // Links
                if (whatsappLink != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "WhatsApp: $whatsappLink",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
                if (facebookLink != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Facebook: $facebookLink",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
                if (websiteLink != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Website: $websiteLink",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
                const SizedBox(height: 16),
                // Ask/Provider
                Text(
                  "Type: ${isAsk ? 'Service Request' : 'Service Provider'}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
