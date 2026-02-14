// Modèl itilizatè pou aplikasyon DeliveRapid
// Gere tout enfòmasyon itilizatè yo (kilyan, livre, admin)

class User {
  // Pwopriyete yo
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // "kilyan", "livre", "admin"
  final String? token;
  final bool isLoggedIn;
  final String? profileImage;
  final DateTime? lastLogin;
  final bool isActive;
  final Map<String, dynamic>? additionalInfo;

  // Konstriktè prensipal
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
    this.additionalInfo,
  });

  // Konstriktè pou kilyan default
  User.client({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.token,
    this.isLoggedIn = false,
    this.profileImage,
    this.lastLogin,
    this.isActive = true,
    this.additionalInfo,
  }) : role = 'kilyan';

  // Konstriktè pou livre default
  User.driver({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.token,
    this.isLoggedIn = false,
    this.profileImage,
    this.lastLogin,
    this.isActive = true,
    this.additionalInfo,
  }) : role = 'livre';

  // Konstriktè pou admin default
  User.admin({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.token,
    this.isLoggedIn = false,
    this.profileImage,
    this.lastLogin,
    this.isActive = true,
    this.additionalInfo,
  }) : role = 'admin';

  // Konvèti JSON an objè User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['firstName'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'kilyan',
      token: json['token'] ?? json['accessToken'],
      isLoggedIn: json['isLoggedIn'] ?? false,
      profileImage: json['profileImage'] ?? json['image'] ?? json['avatar'],
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'])
          : null,
      isActive: json['isActive'] ?? true,
      additionalInfo: json['additionalInfo'] ?? {},
    );
  }

  // Konvèti objè User an JSON
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
      'additionalInfo': additionalInfo,
    };
  }

  // Kreye yon kopi User ak kèk modifikasyon
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
    Map<String, dynamic>? additionalInfo,
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
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // Metòd util pou verifye wòl itilizatè a
  bool get isClient => role == 'kilyan';
  bool get isDriver => role == 'livre';
  bool get isAdmin => role == 'admin';

  // Jwenn non an an majiskil
  String get capitalizedName {
    if (name.isEmpty) return '';
    return name.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Inisyal non an (pou avatar)
  String get initials {
    if (name.isEmpty) return '?';
    List<String> parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }
}