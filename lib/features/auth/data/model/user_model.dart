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
    // Handle image from both 'image_url' and 'image' fields
    String? imageUrl;
    
    // First try to get from image_url (full URL from backend)
    if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      imageUrl = json['image_url'].toString();
    }
    // Then try to get from image field (relative path or URL)
    else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      imageUrl = json['image'].toString();
    }
    
    // Parse total_points - handle both string and int
    int parsedTotalPoints = 0;
    if (json['total_points'] != null) {
      if (json['total_points'] is int) {
        parsedTotalPoints = json['total_points'];
      } else if (json['total_points'] is String) {
        parsedTotalPoints = int.tryParse(json['total_points']) ?? 0;
      } else if (json['total_points'] is double) {
        parsedTotalPoints = (json['total_points'] as double).toInt();
      }
    }
    
    // Parse eco_level - handle different possible values
    String parsedEcoLevel = 'Newbie';
    if (json['eco_level'] != null) {
      final ecoLevelStr = json['eco_level'].toString();
      if (ecoLevelStr.isNotEmpty) {
        parsedEcoLevel = ecoLevelStr;
      }
    }
    
    // Parse date_joined
    DateTime parsedDateJoined = DateTime.now();
    if (json['date_joined'] != null) {
      try {
        parsedDateJoined = DateTime.parse(json['date_joined'].toString());
      } catch (e) {
        print('Error parsing date_joined: $e');
      }
    }
    
    // Parse last_login
    DateTime? parsedLastLogin;
    if (json['last_login'] != null && json['last_login'].toString().isNotEmpty) {
      try {
        parsedLastLogin = DateTime.parse(json['last_login'].toString());
      } catch (e) {
        print('Error parsing last_login: $e');
      }
    }
    
    return UserModel(
      id: (json['id'] is int) ? json['id'] : 
          (json['id'] is String) ? int.tryParse(json['id']) ?? 0 : 0,
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      image: imageUrl,
      totalPoints: parsedTotalPoints,
      ecoLevel: parsedEcoLevel,
      dateJoined: parsedDateJoined,
      lastLogin: parsedLastLogin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'image': imageUrl,
      'total_points': totalPoints,
      'eco_level': ecoLevel,
      'date_joined': dateJoined.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  // Get full name from backend if available, otherwise construct it
  String get fullName {
    // If backend provides full_name, use it
    // Otherwise construct from first_name and last_name
    return '$firstName $lastName'.trim();
  }

  // Helper to get full name from JSON (for debugging)
  static String getFullNameFromJson(Map<String, dynamic> json) {
    if (json['full_name'] != null && json['full_name'].toString().isNotEmpty) {
      return json['full_name'].toString();
    }
    return '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim();
  }

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
  
  @override
  String toString() {
    return '''
  UserModel {
  id: $id,
  email: $email,
  firstName: $firstName,
  lastName: $lastName,
  fullName: $fullName,
  phoneNumber: $phoneNumber,
  image: ${image?.substring(0, image!.length < 30 ? image!.length : 30)}...,
  totalPoints: $totalPoints,
  ecoLevel: $ecoLevel,
  dateJoined: $dateJoined,
  lastLogin: $lastLogin,
  hasImage: $hasImage
}
''';
  }
}