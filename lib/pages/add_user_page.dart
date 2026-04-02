// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../service/user_service.dart';
//
// class AddUserPage extends StatefulWidget {
//   const AddUserPage({super.key});
//
//   @override
//   State<AddUserPage> createState() => _AddUserPageState();
// }
//
// class _AddUserPageState extends State<AddUserPage> {
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final UserService _service = UserService();
//
//   XFile? _image;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add User")),
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
//             const SizedBox(height: 10),
//
//             ElevatedButton(
//               onPressed: () async {
//                 final pickedImage = await _service.pickImage();
//                 setState(() {
//                   _image = pickedImage;
//                 });
//               },
//               child: const Text("Pick Image"),
//             ),
//
//             const SizedBox(height: 20),
//
//             ElevatedButton(
//               onPressed: () async {
//                 await _service.addUser(
//                   _nameController.text,
//                   _emailController.text,
//                   _image,
//                 );
//
//                 Navigator.pop(context);
//               },
//               child: const Text("Save"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }