import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';
import '../models/user_model.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final client = SupabaseConfig.client;

  /// Creates auth user, uploads profile image if provided, and inserts profile row.
  /// Throws on failure so callers can show specific error messages.
  Future<void> signUp(
    String name,
    String email,
    String password,
    XFile? imageFile,
  ) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception("Signup failed");

      String? imageUrl;

      if (imageFile != null) {
        final fileExt = imageFile.name.split('.').last;
        final fileName = '${user.id}.$fileExt';

        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          await client.storage
              .from('user-images')
              .uploadBinary(fileName, bytes,
                  fileOptions: const FileOptions(upsert: true));
        } else {
          final file = File(imageFile.path);
          await client.storage
              .from('user-images')
              .upload(fileName, file,
                  fileOptions: const FileOptions(upsert: true));
        }
        imageUrl = client.storage.from('user-images').getPublicUrl(fileName);
      }

      await client.from('users').insert({
        'id': user.id,
        'name': name,
        'email': email,
        'image_url': imageUrl,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Signs in with email and password. Throws on invalid credentials or network error.
  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      final response = await client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return [];

      final response = await client
          .from('orders')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await client.from('users').select();
      if (response.isEmpty) return [];
      return List<Map<String, dynamic>>.from(response)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<XFile?> pickImage() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  Future<void> updateUser(String name, String email) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("Not signed in");

    await client.from('users').update({
      'name': name,
      'email': email,
    }).eq('id', user.id);
  }

  Future<void> deleteUser(String id) async {
    await client.from('users').delete().eq('id', id);
  }
}
