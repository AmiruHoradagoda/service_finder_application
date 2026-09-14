import 'package:flutter/material.dart';
import 'package:service_finder_application/features/chat/services/chat_service.dart';
import 'package:service_finder_application/shared/widgets/my_list_tile.dart';
import 'package:service_finder_application/core/utils/helper_functions.dart';
import 'package:service_finder_application/routes/app_routes.dart';

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
          stream: ChatService().getUsersStream(),
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
            final users = snapshot.data!;

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

                      final username = user.username ?? 'Unknown user';
                      final email = user.email ?? '';
                      final userID = user.userId;

                      return GestureDetector(
                        onTap: () {
                          AppRoutes.openChat(
                            context,
                            receiverUserEmail: email,
                            receiverUserID: userID,
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
