// Simple user model without code generation

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String? profileImageUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final List<String> clubIds;
  final Map<String, dynamic> preferences;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.clubIds = const [],
    this.preferences = const {},
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      clubIds: List<String>.from(json['clubIds'] as List? ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'clubIds': clubIds,
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? profileImageUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? clubIds,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      clubIds: clubIds ?? this.clubIds,
      preferences: preferences ?? this.preferences,
    );
  }
}

class CreateUserRequest {
  final String email;
  final String name;
  final String phone;
  final String? bio;

  const CreateUserRequest({
    required this.email,
    required this.name,
    required this.phone,
    this.bio,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'bio': bio,
    };
  }
}

class VendorUser {
  final String id;
  final String email;
  final String name;
  final String? businessName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final List<String> permissions;
  final String role; // admin, manager, staff

  const VendorUser({
    required this.id,
    required this.email,
    required this.name,
    this.businessName,
    this.phoneNumber,
    this.profileImageUrl,
    this.isVerified = false,
    required this.createdAt,
    this.lastLoginAt,
    this.permissions = const [],
    this.role = 'staff',
  });

  factory VendorUser.fromMap(Map<String, dynamic> map) {
    return VendorUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      businessName: map['businessName'],
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'])
          : null,
      permissions: List<String>.from(map['permissions'] ?? []),
      role: map['role'] ?? 'staff',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'businessName': businessName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
      'permissions': permissions,
      'role': role,
    };
  }

  VendorUser copyWith({
    String? id,
    String? email,
    String? name,
    String? businessName,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? permissions,
    String? role,
  }) {
    return VendorUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      permissions: permissions ?? this.permissions,
      role: role ?? this.role,
    );
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission) || role == 'admin';
  }

  @override
  String toString() {
    return 'VendorUser(id: $id, email: $email, name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 