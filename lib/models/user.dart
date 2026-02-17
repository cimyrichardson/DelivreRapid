class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? token;
  final bool isLoggedIn;
  final String? profileImage;
  final DateTime? lastLogin;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.token,
    this.isLoggedIn = false,
    this.profileImage,
    this.lastLogin,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['firstName'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'kilyan',
      token: json['token'],
      isLoggedIn: json['isLoggedIn'] ?? false,
      profileImage: json['profileImage'] ?? json['image'],
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'token': token,
      'isLoggedIn': isLoggedIn,
      'profileImage': profileImage,
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? token,
    bool? isLoggedIn,
    String? profileImage,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      profileImage: profileImage ?? this.profileImage,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isClient => role == 'kilyan';
  bool get isDriver => role == 'livre';
  bool get isAdmin => role == 'admin';

  String get initials {
    if (name.isEmpty) return '?';
    List<String> parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}