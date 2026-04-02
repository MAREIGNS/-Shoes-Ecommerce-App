import 'package:flutter/material.dart';
import 'package:shoescomm/service/user_service.dart';
import '../models/user_model.dart';
import 'add_user_page.dart';
import 'edit_user_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final UserService _service = UserService.instance;
  late Future<List<UserModel>> _users;

  @override
  void initState() {
    super.initState();
    _users = _service.getUsers();
  }

  void refresh() {
    setState(() {
      _users = _service.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Users CRUD")),

      body: FutureBuilder<List<UserModel>>(
        future: _users,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Get users
          final users = snapshot.data ?? [];

          // Empty state
          if (users.isEmpty) {
            return const Center(child: Text('No Users Found'));
          }

          // Display list of users
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: user.imageUrl != null
                    ? Image.network(
                  user.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.person, size: 50),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button
                    // IconButton(
                    //   icon: const Icon(Icons.edit, color: Colors.blue),
                    //   onPressed: () async {
                    //     await Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => EditUserPage(user: user),
                    //       ),
                    //     );
                    //     refresh();
                    //   },
                    // ),
                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _service.deleteUser(user.id);
                        refresh();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}