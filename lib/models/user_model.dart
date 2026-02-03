class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String description;
  final double rating;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.description,
    this.rating = 4.5,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'Client',
      description: map['description'] ?? '',
      rating: (map['rating'] ?? 4.5).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'description': description,
      'rating': rating,
    };
  }
}
