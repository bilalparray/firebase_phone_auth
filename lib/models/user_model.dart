class UserModel {
  String? uid;
  String? email;
  String? name;
  String? bio;
  String? profilePic;
  String? createdAt;
  String? phoneNumber;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.bio,
    required this.profilePic,
    required this.createdAt,
    required this.phoneNumber,
  });

  ///from map to user model
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        name: map['name'],
        email: map['email'],
        uid: map['uid'],
        bio: map['bio'],
        profilePic: map['profilePic'],
        createdAt: map['createdAt'],
        phoneNumber: map['phoneNumber']);
  }

  //from user to map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'uid': uid,
      'bio': bio,
      'profilePic': profilePic,
      'createdAt': createdAt,
      'phoneNumber': phoneNumber,
    };
  }
}
