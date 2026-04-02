// import 'package:flutter/material.dart';
// import 'package:shoescomm/service/user_service.dart';
// import '../models/user_model.dart';
// // import '../services/user_service.dart';
//
// class EditUserPage extends StatefulWidget {
//   final UserModel user;
//
//   const EditUserPage({super.key, required this.user});
//
//   @override
//   State<EditUserPage> createState() => _EditUserPageState();
// }
//
// class _EditUserPageState extends State<EditUserPage> {
//   final UserService _service = UserService();
//   late TextEditingController _nameController;
//   late TextEditingController _emailController;
//
//   @override
//   void initState() {
//     _nameController =
//         TextEditingController(text: widget.user.name);
//     _emailController =
//         TextEditingController(text: widget.user.email);
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Edit User")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: "Name"),
//             ),
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: "Email"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 await _service.updateUser(
//                   widget.user.id,
//                   _nameController.text,
//                   _emailController.text,
//                 );
//                 Navigator.pop(context);
//               },
//               child: const Text("Update"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }