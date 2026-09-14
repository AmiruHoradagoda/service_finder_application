import 'package:cloud_firestore/cloud_firestore.dart';

/// A provider listing or service request, using the existing Posts field names.
class ServicePost {
  ServicePost({
    required this.id,
    required this.userId,
    required this.message,
    required this.isAsk,
    this.userEmail,
    this.username,
    this.description = '',
    this.mobile1 = '',
    this.mobile2,
    this.address = '',
    this.whatsappLink,
    this.facebookLink,
    this.websiteLink,
    this.location = '',
    List<String> imageUrls = const [],
    this.timestamp,
  }) : imageUrls = List<String>.unmodifiable(imageUrls);

  final String id;
  final String userId;
  final String? userEmail;
  final String? username;
  final String message;
  // Missing legacy flags must not classify a post into either Home feed.
  final bool? isAsk;
  final String description;
  final String mobile1;
  final String? mobile2;
  final String address;
  final String? whatsappLink;
  final String? facebookLink;
  final String? websiteLink;
  final String location;
  final List<String> imageUrls;
  final Timestamp? timestamp;

  factory ServicePost.fromMap(Map<String, dynamic> data,
          {String? documentId}) =>
      ServicePost(
        id: data['post_ID'] as String? ?? documentId ?? '',
        userId: data['UserID'] as String? ?? '',
        userEmail: data['UserEmail'] as String?,
        username: data['username'] as String?,
        message: data['PostMessage'] as String? ?? '',
        isAsk: data['ask'] as bool?,
        description: data['Description'] as String? ?? '',
        mobile1: data['Mobile1'] as String? ?? '',
        mobile2: data['Mobile2'] as String?,
        address: data['Address'] as String? ?? '',
        whatsappLink: data['WhatsappLink'] as String?,
        facebookLink: data['FacebookLink'] as String?,
        websiteLink: data['WebsiteLink'] as String?,
        location: data['Location'] as String? ?? '',
        imageUrls: (data['ImageUrls'] as List?)?.cast<String>() ?? const [],
        timestamp: data['TimeStamp'] as Timestamp?,
      );

  Map<String, dynamic> toMap() => {
        'post_ID': id,
        'UserID': userId,
        'UserEmail': userEmail,
        'username': username,
        'PostMessage': message,
        'ask': isAsk,
        'Description': description,
        'Mobile1': mobile1,
        'Mobile2': mobile2,
        'Address': address,
        'WhatsappLink': whatsappLink,
        'FacebookLink': facebookLink,
        'WebsiteLink': websiteLink,
        'Location': location,
        'ImageUrls': imageUrls,
        'TimeStamp': timestamp,
      };
}
