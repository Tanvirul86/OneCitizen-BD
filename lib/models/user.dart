enum UserRole { citizen, admin }

UserRole roleFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.citizen;
  }
}

String roleToString(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'admin';
    case UserRole.citizen:
      return 'citizen';
  }
}

/// A registered user — citizen or admin. Field set follows the ER `CITIZEN`
/// table plus the extra profile attributes (occupation/income/land/GPA) the
/// eligibility checker needs.
class User {
  const User({
    required this.id,
    required this.email,
    this.username,
    this.nid,
    this.firstName,
    this.lastName,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.occupation,
    this.income,
    this.landAcres,
    this.sscGpa,
    this.hscGpa,
    this.profilePictureUrl,
    this.role = UserRole.citizen,
    this.verified = false,
    this.isActive = true,
  });

  final String id;
  final String email;
  final String? username;
  final String? nid;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? occupation;
  final double? income;
  final double? landAcres;
  final double? sscGpa;
  final double? hscGpa;
  final String? profilePictureUrl;
  final UserRole role;
  final bool verified;
  final bool isActive;

  String get fullName => [firstName, lastName].where((s) => s != null && s.isNotEmpty).join(' ');

  /// True once the eligibility-relevant profile fields are filled in.
  bool get profileComplete =>
      dateOfBirth != null && occupation != null && address != null;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String?,
      nid: json['nid'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      occupation: json['occupation'] as String?,
      income: (json['income'] as num?)?.toDouble(),
      landAcres: (json['land_acres'] as num?)?.toDouble(),
      sscGpa: (json['ssc_gpa'] as num?)?.toDouble(),
      hscGpa: (json['hsc_gpa'] as num?)?.toDouble(),
      profilePictureUrl: json['profile_picture'] as String?,
      role: roleFromString(json['role'] as String?),
      verified: json['verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
        'gender': gender,
        'address': address,
        'occupation': occupation,
        'income': income,
        'land_acres': landAcres,
        'ssc_gpa': sscGpa,
        'hsc_gpa': hscGpa,
      };

  User copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? occupation,
    double? income,
    double? landAcres,
    double? sscGpa,
    double? hscGpa,
    String? profilePictureUrl,
  }) {
    return User(
      id: id,
      email: email,
      username: username,
      nid: nid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      occupation: occupation ?? this.occupation,
      income: income ?? this.income,
      landAcres: landAcres ?? this.landAcres,
      sscGpa: sscGpa ?? this.sscGpa,
      hscGpa: hscGpa ?? this.hscGpa,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role,
      verified: verified,
      isActive: isActive,
    );
  }
}
