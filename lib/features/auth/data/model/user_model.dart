class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? image;
  final int totalPoints;
  final String ecoLevel;
  final DateTime dateJoined;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.image,
    this.totalPoints = 0,
    this.ecoLevel = 'Beginner',
    required this.dateJoined,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      image: json['image'],
      totalPoints: json['total_points'] ?? 0,
      ecoLevel: json['eco_level'] ?? 'Beginner',
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'])
          : DateTime.now(),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'image': image,
      'total_points': totalPoints,
      'eco_level': ecoLevel,
      'date_joined': dateJoined.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

  UserModel copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? image,
    int? totalPoints,
    String? ecoLevel,
    DateTime? dateJoined,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      image: image ?? this.image,
      totalPoints: totalPoints ?? this.totalPoints,
      ecoLevel: ecoLevel ?? this.ecoLevel,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  factory UserModel.empty() {
    return UserModel(
      id: 0,
      email: '',
      firstName: '',
      lastName: '',
      phoneNumber: '',
      dateJoined: DateTime.now(),
    );
  }

  bool get isEmpty => id == 0;
  
  bool get hasImage => image != null && image!.isNotEmpty;
  
  String? get imageUrl => hasImage ? image : null;
}