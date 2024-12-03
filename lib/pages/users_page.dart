import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/components/my_list_tile.dart';
import 'package:service_finder_application/helper/helper_functions.dart';
import 'package:service_finder_application/pages/chat_page.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("Users").snapshots(),
          builder: (context, snapshot) {
            // any errors
            if (snapshot.hasError) {
              displayMessageToUser("Something went wrong", context);
            }

            // show loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data == null) {
              return const Text("No data found!");
            }

            // get all users
            final users = snapshot.data!.docs;

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    padding: const EdgeInsets.all(0),
                    itemBuilder: (context, index) {
                      // get individual user
                      final user = users[index];

                      String username = user['username'];
                      String email = user['email'];
                      String userID = user['user_ID'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                receiverUserEmail: email,
                                receiverUserID: userID,
                              ),
                            ),
                          );
                        },
                        child: MyListTile(
                          title: username,
                          subtitle: email,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
