class Room {
  Room({
    this.id,
    this.name,
    this.facultyName,
    this.photo,
    this.capacity,
    this.status,
    this.raw = const {},
  });

  final dynamic id;
  final String? name;
  final String? facultyName;
  final String? photo;
  final int? capacity;
  final String? status;
  final Map<String, dynamic> raw;

  String get displayName =>
      (name != null && name!.trim().isNotEmpty) ? name!.trim() : 'Ruangan';

  String get displayFaculty =>
      (facultyName != null && facultyName!.trim().isNotEmpty)
      ? facultyName!.trim()
      : 'Fakultas tidak diketahui';

  String get displayStatus => (status != null && status!.trim().isNotEmpty)
      ? status!.trim()
      : 'Status tidak diketahui';

  bool get hasPhoto => photo != null && photo!.trim().isNotEmpty;

  Room copyWith({
    dynamic id,
    String? name,
    String? facultyName,
    String? photo,
    int? capacity,
    String? status,
    Map<String, dynamic>? raw,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      facultyName: facultyName ?? this.facultyName,
      photo: photo ?? this.photo,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      raw: raw ?? this.raw,
    );
  }

  static Room fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'],
      name: _pickString(map, const ['name']),
      facultyName: _pickString(map, const ['faculty_name', 'facultyName']),
      photo: _pickString(map, const ['photo', 'photo_url', 'image']),
      capacity: _parseCapacity(map['capacity']),
      status: _pickString(map, const ['status', 'room_status']),
      raw: Map<String, dynamic>.from(map),
    );
  }

  static String? _pickString(
    Map<String, dynamic> map,
    List<String> candidates,
  ) {
    for (final key in candidates) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static int? _parseCapacity(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      return int.tryParse(trimmed);
    }
    return null;
  }
}
