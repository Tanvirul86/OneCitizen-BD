enum UserRole { citizen, officer, admin }

UserRole roleFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'officer':
      return UserRole.officer;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.citizen;
  }
}

String roleToString(UserRole role) {
  switch (role) {
    case UserRole.officer:
      return 'officer';
    case UserRole.admin:
      return 'admin';
    case UserRole.citizen:
      return 'citizen';
  }
}

class User {
  const User({
    required this.id,
    required this.phoneNumber,
    this.fullName,
    this.nid,
    this.email,
    this.address,
    this.occupation,
    this.dateOfBirth,
    this.profilePictureUrl,
    this.citizenId,
    this.role = UserRole.citizen,
    this.isActive = true,
    this.income,
    this.landHolding,
  });

  final String id;
  final String phoneNumber;
  final String? fullName;
  final String? nid;
  final String? email;
  final String? address;
  final String? occupation;
  final DateTime? dateOfBirth;
  final String? profilePictureUrl;
  final String? citizenId;
  final UserRole role;
  final bool isActive;
  final double? income;
  final double? landHolding;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      fullName: json['full_name'] as String?,
      nid: json['nid'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      occupation: json['occupation'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      profilePictureUrl: json['profile_picture'] as String?,
      citizenId: json['citizen_id'] as String?,
      role: roleFromString(json['role'] as String?),
      isActive: json['is_active'] as bool? ?? true,
      income: (json['income'] as num?)?.toDouble(),
      landHolding: (json['land_holding'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'nid': nid,
        'email': email,
        'address': address,
        'occupation': occupation,
        'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
        'income': income,
        'land_holding': landHolding,
      };

  User copyWith({
    String? fullName,
    String? nid,
    String? email,
    String? address,
    String? occupation,
    DateTime? dateOfBirth,
    String? profilePictureUrl,
    double? income,
    double? landHolding,
  }) {
    return User(
      id: id,
      phoneNumber: phoneNumber,
      fullName: fullName ?? this.fullName,
      nid: nid ?? this.nid,
      email: email ?? this.email,
      address: address ?? this.address,
      occupation: occupation ?? this.occupation,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      citizenId: citizenId,
      role: role,
      isActive: isActive,
      income: income ?? this.income,
      landHolding: landHolding ?? this.landHolding,
    );
  }
}
