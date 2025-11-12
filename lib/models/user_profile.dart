class UserProfile {
  UserProfile({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.raw = const {},
  });

  final dynamic id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final Map<String, dynamic> raw;

  String get displayName =>
      (name?.trim().isNotEmpty ?? false) ? name!.trim() : 'Pengguna';

  UserProfile copyWith({
    dynamic id,
    String? name,
    String? email,
    String? phone,
    String? role,
    Map<String, dynamic>? raw,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      raw: raw ?? this.raw,
    );
  }

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: _pickFirstNonEmpty(map, const [
        'name',
        'nama',
        'fullName',
        'full_name',
      ]),
      email: _pickFirstNonEmpty(map, const ['email', 'email_address']),
      phone: _pickFirstNonEmpty(map, const [
        'phone',
        'phoneNumber',
        'phone_number',
        'no_hp',
        'telepon',
      ]),
      role: _pickFirstNonEmpty(map, const [
        'role',
        'roles',
        'jabatan',
        'position',
      ]),
      raw: Map<String, dynamic>.from(map),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'raw': raw,
    };
  }

  static String? _pickFirstNonEmpty(
    Map<String, dynamic> map,
    List<String> candidateKeys,
  ) {
    for (final key in candidateKeys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}
