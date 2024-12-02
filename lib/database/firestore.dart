import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDatabase {
  // Current logged-in user
  User? user = FirebaseAuth.instance.currentUser;

  // Collection reference for posts
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('Posts');
  final CollectionReference users = FirebaseFirestore.instance
      .collection('Users'); // Reference for Users collection

  // Method to fetch username from the Users collection
  Future<String?> getUsername(String userId) async {
    try {
      DocumentSnapshot userDoc = await users
          .doc(user?.email)
          .get(); // Fetch using email as document ID
      if (userDoc.exists) {
        return userDoc['username'] as String?;
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
    return null;
  }

  // Method to add a post with additional fields including username
  Future<void> addPost({
    required String message,
    required bool isAsk,
    required String description,
    required String mobile1,
    String? mobile2,
    required String address,
    String? whatsappLink,
    String? facebookLink,
    String? websiteLink,
    List<String>? imageUrls,
    required String userId,
    required String postId, required String location,
  }) async {
    try {
      // Fetch the username of the user
      String? username = await getUsername(userId);

      // Create a new document reference
      DocumentReference docRef = posts.doc();

      // Use the document ID as the post_ID
      String postId = docRef.id;

      // Add the post data with post_ID, user_ID, and username included
      await docRef.set({
        'post_ID': postId,
        'UserEmail': user?.email,
        'UserID': userId,
        'username': username, 
        'PostMessage': message,
        'Description': description,
        'Mobile1': mobile1,
        'Mobile2': mobile2,
        'Address': address,
        'WhatsappLink': whatsappLink,
        'FacebookLink': facebookLink,
        'WebsiteLink': websiteLink,
        'ImageUrls': imageUrls, 
        'TimeStamp': Timestamp.now(),
        'ask': isAsk, // Field to differentiate between Ask and Provider posts
      });
    } catch (e) {
      print("Error adding post: $e");
    }
  }

  // Method to get a post by post_ID
  Future<DocumentSnapshot> getPostById(String postId) async {
    try {
      DocumentSnapshot postSnapshot = await posts.doc(postId).get();
      return postSnapshot;
    } catch (e) {
      rethrow;
    }
  }

  // Method to stream posts (add this method)
  Stream<QuerySnapshot> getPostsStream() {
    return posts.orderBy('TimeStamp', descending: true).snapshots();
  }
}
