class TeamContact {
  final int userId;
  final String name;
  final String designation;
  final String role;
  final String? phone;
  final String? email;
  final String? photoUrl;

  const TeamContact({
    required this.userId,
    required this.name,
    required this.designation,
    required this.role,
    this.phone,
    this.email,
    this.photoUrl,
  });

  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get hasEmail => email != null && email!.isNotEmpty;

  factory TeamContact.fromJson(Map<String, dynamic> json) => TeamContact(
        userId: (json['userId'] as num).toInt(),
        name: json['name'] as String? ?? 'Unnamed',
        designation: json['designation'] as String? ?? '',
        role: json['role'] as String? ?? '',
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        photoUrl: json['photoUrl'] as String?,
      );
}
