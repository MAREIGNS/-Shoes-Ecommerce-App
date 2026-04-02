class UserModel {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'image_url': imageUrl,
    };
  }
}