class UserModel {
  final String name;
  final String email;
  final String profilePic;
  final String uid;
  final String? token;

  //<editor-fold desc="Data Methods">
  const UserModel({
    required this.name,
    required this.email,
    required this.profilePic,
    required this.uid,
    this.token,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          profilePic == other.profilePic &&
          uid == other.uid &&
          token == other.token);

  @override
  int get hashCode =>
      name.hashCode ^
      email.hashCode ^
      profilePic.hashCode ^
      uid.hashCode ^
      token.hashCode;

  @override
  String toString() {
    return 'UserModel{' +
        ' name: $name,' +
        ' email: $email,' +
        ' profilePic: $profilePic,' +
        ' uid: $uid,' +
        ' token: $token,' +
        '}';
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? profilePic,
    String? uid,
    String? token,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      uid: uid ?? this.uid,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'email': this.email,
      'profilePic': this.profilePic,
      'uid': this.uid,
      'token': this.token,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePic: map['profilePic'] ?? '',
      uid: map['_id'] ?? '',
      token: map['token'] ?? '',
    );
  }

  //</editor-fold>
}
