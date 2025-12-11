import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:simaru/models/room.dart';

class RoomService extends GetxService {
  RoomService({http.Client? client}) : _client = client ?? http.Client();

  static const String _apiHost = 'http://127.0.0.1:8001';
  static const String _baseUrl = '$_apiHost/api';
  final http.Client _client;

  Future<List<Room>> fetchRooms() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/rooms'),
        headers: _jsonHeaders(),
      );

      if (response.statusCode == 200) {
        final payload = _decodeJson(response.body);
        final roomMaps = _extractRoomMaps(payload);
        return roomMaps.map(Room.fromMap).map(_resolvePhotoUrl).toList();
      }

      _log('Failed to fetch rooms: ${response.statusCode}');
      _log('Response body: ${response.body}');
      throw Exception(
        'Gagal memuat data ruangan (kode: ${response.statusCode}).',
      );
    } catch (e) {
      _log('Error fetching rooms: $e');
      rethrow;
    }
  }

  Room _resolvePhotoUrl(Room room) {
    final photo = room.photo?.trim();
    if (photo == null || photo.isEmpty) {
      return room;
    }

    final uri = Uri.tryParse(photo);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return room;
    }

    var sanitizedPath = photo.startsWith('/') ? photo.substring(1) : photo;

    if (!sanitizedPath.startsWith('storage/')) {
      sanitizedPath = 'storage/$sanitizedPath';
    }

    final resolved = Uri.parse('$_apiHost/$sanitizedPath').toString();
    return room.copyWith(photo: resolved);
  }

  Future<Room> createRoom({
    required String name,
    String? facultyName,
    int? capacity,
    String? status,
    String? photo,
    PlatformFile? photoFile,
    String? token,
  }) async {
    try {
      if (photoFile != null) {
        return _sendMultipartRoom(
          uri: Uri.parse('$_baseUrl/rooms'),
          name: name,
          facultyName: facultyName,
          capacity: capacity,
          status: status,
          photoFile: photoFile,
          token: token,
        );
      }

      final response = await _client.post(
        Uri.parse('$_baseUrl/rooms'),
        headers: _jsonHeaders(token),
        body: jsonEncode({
          'name': name,
          if (facultyName != null) 'faculty_name': facultyName,
          if (capacity != null) 'capacity': capacity,
          if (status != null) 'status': status,
          if (photo != null) 'photo': photo,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final payload = _decodeJson(response.body);
        final roomMap = _extractRoomMap(payload);
        if (roomMap != null) {
          return _resolvePhotoUrl(Room.fromMap(roomMap));
        }
      }

      throw Exception(
        'Gagal menambahkan ruangan (kode: ${response.statusCode}).',
      );
    } catch (e) {
      _log('Error creating room: $e');
      rethrow;
    }
  }

  Future<Room> updateRoom({
    required dynamic id,
    required String name,
    String? facultyName,
    int? capacity,
    String? status,
    String? photo,
    PlatformFile? photoFile,
    String? token,
  }) async {
    try {
      if (photoFile != null) {
        return _sendMultipartRoom(
          uri: Uri.parse('$_baseUrl/rooms/$id'),
          name: name,
          facultyName: facultyName,
          capacity: capacity,
          status: status,
          photoFile: photoFile,
          token: token,
          usePutOverride: true,
        );
      }

      final response = await _client.put(
        Uri.parse('$_baseUrl/rooms/$id'),
        headers: _jsonHeaders(token),
        body: jsonEncode({
          'name': name,
          if (facultyName != null) 'faculty_name': facultyName,
          if (capacity != null) 'capacity': capacity,
          if (status != null) 'status': status,
          if (photo != null) 'photo': photo,
        }),
      );

      if (response.statusCode == 200) {
        final payload = _decodeJson(response.body);
        final roomMap = _extractRoomMap(payload);
        if (roomMap != null) {
          return _resolvePhotoUrl(Room.fromMap(roomMap));
        }
      }

      throw Exception(
        'Gagal memperbarui ruangan (kode: ${response.statusCode}).',
      );
    } catch (e) {
      _log('Error updating room: $e');
      rethrow;
    }
  }

  Future<void> deleteRoom(dynamic id, {String? token}) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/rooms/$id'),
        headers: _jsonHeaders(token),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw Exception(
        'Gagal menghapus ruangan (kode: ${response.statusCode}).',
      );
    } catch (e) {
      _log('Error deleting room: $e');
      rethrow;
    }
  }

  Map<String, String> _jsonHeaders([String? token]) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null && token.trim().isNotEmpty)
      'Authorization': 'Bearer ${token.trim()}',
  };

  Map<String, String> _multipartHeaders([String? token]) => {
    'Accept': 'application/json',
    if (token != null && token.trim().isNotEmpty)
      'Authorization': 'Bearer ${token.trim()}',
  };

  Map<String, dynamic>? _extractRoomMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      if (payload['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(payload['data']);
      }
      return payload;
    }
    return null;
  }

  dynamic _decodeJson(String source) {
    try {
      return jsonDecode(source);
    } catch (e) {
      _log('Failed to decode room payload: $e');
      return null;
    }
  }

  Future<Room> _sendMultipartRoom({
    required Uri uri,
    required String name,
    String? facultyName,
    int? capacity,
    String? status,
    required PlatformFile photoFile,
    String? token,
    bool usePutOverride = false,
  }) async {
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_multipartHeaders(token));
    request.fields['name'] = name;
    if (facultyName != null) request.fields['faculty_name'] = facultyName;
    if (capacity != null) request.fields['capacity'] = capacity.toString();
    if (status != null) request.fields['status'] = status;
    if (usePutOverride) request.fields['_method'] = 'PUT';

    final bytes = _resolveFileBytes(photoFile);
    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: (photoFile.name.isNotEmpty ? photoFile.name : 'photo.jpg'),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final payload = _decodeJson(response.body);
      final roomMap = _extractRoomMap(payload);
      if (roomMap != null) {
        return _resolvePhotoUrl(Room.fromMap(roomMap));
      }
    }

    throw Exception(
      'Gagal mengirim data ruangan (kode: ${response.statusCode}).',
    );
  }

  Uint8List _resolveFileBytes(PlatformFile file) {
    final bytes = file.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      return bytes;
    }

    throw Exception('File foto tidak memiliki data.');
  }

  List<Map<String, dynamic>> _extractRoomMaps(dynamic payload) {
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((map) => Map<String, dynamic>.from(map))
          .toList();
    }

    if (payload is Map) {
      final candidates = [payload['data'], payload['rooms'], payload['items']];
      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map((map) => Map<String, dynamic>.from(map))
              .toList();
        }
      }
    }

    return const [];
  }

  void _log(String message) {
    debugPrint('RoomService: $message');
  }
}
