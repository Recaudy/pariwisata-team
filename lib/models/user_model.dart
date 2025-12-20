class UserModel {
  String uid;
  String name;
  String email;
  String? photoUrl;
  String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'Guest',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      role: map['role'] ?? 'User',
    );
  }
}
