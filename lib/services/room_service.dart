import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' show Client;
import 'package:simaru/models/room.dart';

class RoomService extends GetxService {
  RoomService({Client? client}) : _client = client ?? Client();

  static const String _baseUrl = 'http://127.0.0.1:8001/api';
  final Client _client;

  Future<List<Room>> fetchRooms() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/rooms'),
        headers: const {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final payload = _decodeJson(response.body);
        final roomMaps = _extractRoomMaps(payload);
        return roomMaps.map(Room.fromMap).toList();
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

  dynamic _decodeJson(String source) {
    try {
      return jsonDecode(source);
    } catch (e) {
      _log('Failed to decode room payload: $e');
      return null;
    }
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
