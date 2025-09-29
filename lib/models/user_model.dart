class User {
  final String id;
  final String name;
  final String department;
  final String roleId;   // This will be derived or empty
  final String roleType; // This comes directly from API
  final String? username;
  final String? email;
  final bool active; // ✅ new

  User({
    required this.id,
    required this.name,
    required this.department,
    required this.roleId,
    required this.roleType,
    this.username,
    this.email,
    this.active = true,// default true
  });

  factory User.fromJson(Map<String, dynamic> json) {
  // Handle both 'role_type' and 'computed_role_type' from API
  String roleType = json['computed_role_type']?.toString() ?? 
                   json['role_type']?.toString() ?? 
                   'Unknown';

  // Map roleType back to roleId (reverse mapping)
  final reverseRoleMap = {
    'User': 'R01',
    'Admin': 'R02', 
    'Super Admin': 'R03',
    'Organization': 'R01',
    'Adviser': 'R01',
    'Staff': 'R01',
  };

  String roleId = json['role_id']?.toString() ?? reverseRoleMap[roleType] ?? '';

  return User(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    department: json['department']?.toString() ?? '',
    roleId: roleId,
    roleType: roleType,
    username: json['username']?.toString(),
    email: json['email']?.toString(),

    // 🔑 Normalize active properly
    active: (json['active'] == 1 || json['active'] == true),
  );
}

  Map<String, dynamic> toJson() {
  return {
    'id': id,
    'name': name,
    'department': department,
    'role_id': roleId,
    'role_type': roleType,
    'username': username,
    'email': email,
    'active': active ? 1 : 0, // 🔑 always send as int
  };
}


  // Create a copy of this User with some fields updated
  User copyWith({
    String? id,
    String? name,
    String? department,
    String? roleId,
    String? roleType,
    String? username,
    String? email,
    bool? active, // ✅ new
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      department: department ?? this.department,
      roleId: roleId ?? this.roleId,
      roleType: roleType ?? this.roleType,
      username: username ?? this.username,
      email: email ?? this.email,
      active: active ?? this.active, // ✅ keep existing if not passed
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, department: $department, roleId: $roleId, roleType: $roleType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class LoginResponse {
  final String token;
  final String roleId;
  final String name;

  LoginResponse({
    required this.token,
    required this.roleId,
    required this.name,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      roleId: json['role_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'role_id': roleId,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'LoginResponse(token: ${token.substring(0, 10)}..., roleId: $roleId, name: $name)';
  }
}