import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simaru/models/room.dart';
import 'package:simaru/models/user_profile.dart';
import 'package:simaru/services/room_service.dart';

class HomeController extends GetxController {
  HomeController({
    String? initialUserName,
    UserProfile? initialUserProfile,
    String? initialAccessToken,
  }) {
    _applyUserProfile(initialUserProfile);
    _applyUserName(initialUserName ?? initialUserProfile?.name);
    _applyAccessToken(initialAccessToken);
  }

  static const String _defaultUserName = 'Pengguna';

  final userName = _defaultUserName.obs;
  final Rxn<UserProfile> userProfile = Rxn<UserProfile>();
  final RxnString accessToken = RxnString();
  final isLoading = false.obs;
  final selectedTabIndex = 0.obs;
  final rooms = <Room>[].obs;
  final roomsError = RxnString();
  final roomsLoading = false.obs;

  final unigalColor = const Color(0xFF592974);

  final RoomService _roomService = Get.find<RoomService>();
  bool _hasLoadedRooms = false;

  @override
  void onReady() {
    super.onReady();
    fetchArguments();
  }

  void fetchArguments() {
    final dynamic arguments = Get.arguments;
    final dynamic parameters = Get.parameters;

    final profile =
        _resolveProfileFromPayload(arguments) ??
        _resolveProfileFromPayload(parameters);
    final resolvedName =
        _resolveNameFromPayload(arguments) ??
        _resolveNameFromPayload(parameters) ??
        profile?.name;
    final token =
        _resolveTokenFromPayload(arguments) ??
        _resolveTokenFromPayload(parameters);

    final appliedName = _applyUserName(resolvedName);
    if (!appliedName) {
      debugPrint(
        'HomeController: No valid username argument. Using current value: ${userName.value}',
      );
    }

    _applyUserProfile(profile);
    _applyAccessToken(token);
  }

  void changeTabIndex(int index) {
    selectedTabIndex.value = index;
    if (index == 2) {
      loadRooms();
    }
  }

  void fetchHomeData() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Fetching home data...');
      await loadRooms(forceRefresh: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadRooms({bool forceRefresh = false}) async {
    if (roomsLoading.value) {
      return;
    }

    if (!forceRefresh && _hasLoadedRooms) {
      return;
    }

    roomsLoading.value = true;
    roomsError.value = null;

    try {
      final fetchedRooms = await _roomService.fetchRooms();
      rooms.assignAll(fetchedRooms);
      _hasLoadedRooms = true;
    } catch (e) {
      final message = e.toString();
      roomsError.value = message;
      debugPrint('HomeController: Failed to load rooms: $message');
    } finally {
      roomsLoading.value = false;
    }
  }

  void logout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Apakah Anda yakin ingin keluar?',
      textConfirm: 'Ya',
      textCancel: 'Tidak',
      confirmTextColor: Colors.white,
      buttonColor: unigalColor,
      cancelTextColor: unigalColor,
      onConfirm: () {
        Get.offAllNamed('/login');
      },
    );
  }

  bool _applyUserName(String? maybeName) {
    final trimmed = maybeName?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      if (userName.value != trimmed) {
        userName.value = trimmed;
        debugPrint('HomeController updated userName: ${userName.value}');
      }
      return true;
    }
    return false;
  }

  void _applyUserProfile(UserProfile? profile) {
    if (profile == null) {
      return;
    }

    final current = userProfile.value;
    if (current == null || current.raw != profile.raw) {
      userProfile.value = profile;
      debugPrint('HomeController stored userProfile: ${profile.toMap()}');
      if (profile.name != null && profile.name!.trim().isNotEmpty) {
        _applyUserName(profile.name);
      }
    }
  }

  void _applyAccessToken(String? token) {
    final trimmed = token?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      if (accessToken.value != trimmed) {
        accessToken.value = trimmed;
        debugPrint('HomeController stored accessToken');
      }
    }
  }

  String? _resolveNameFromPayload(dynamic payload) {
    if (payload == null) {
      return null;
    }

    if (payload is String) {
      final trimmed = payload.trim();
      return trimmed.isNotEmpty ? trimmed : null;
    }

    if (payload is Iterable) {
      for (final element in payload) {
        final candidate = _resolveNameFromPayload(element);
        if (candidate != null && candidate.isNotEmpty) {
          return candidate;
        }
      }
      return null;
    }

    if (payload is Map) {
      for (final entry in payload.entries) {
        final keyString = entry.key.toString().toLowerCase();
        final value = entry.value;

        if (value is String) {
          if ((keyString.contains('name') || keyString.contains('nama')) &&
              value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      }

      for (final value in payload.values) {
        if (value is Map || value is Iterable) {
          final nestedName = _resolveNameFromPayload(value);
          if (nestedName != null && nestedName.isNotEmpty) {
            return nestedName;
          }
        }
      }
    }

    return null;
  }

  UserProfile? _resolveProfileFromPayload(dynamic payload) {
    final map = _extractProfileMap(payload);
    if (map == null || map.isEmpty) {
      return null;
    }

    try {
      return UserProfile.fromMap(map);
    } catch (e) {
      debugPrint('HomeController: Failed to parse user profile: $e');
      return null;
    }
  }

  Map<String, dynamic>? _extractProfileMap(dynamic payload) {
    if (payload == null) {
      return null;
    }

    if (payload is Map) {
      final dynamic direct =
          payload['user'] ??
          payload['profile'] ??
          payload['data'] ??
          payload['account'];
      if (direct is Map<String, dynamic>) {
        return direct;
      }
      if (direct is Map) {
        return Map<String, dynamic>.from(direct);
      }

      if (_containsProfileKeys(payload)) {
        return Map<String, dynamic>.from(
          payload.map((key, value) => MapEntry(key.toString(), value)),
        );
      }

      for (final value in payload.values) {
        if (value is Map || value is Iterable) {
          final nested = _extractProfileMap(value);
          if (nested != null && nested.isNotEmpty) {
            return nested;
          }
        }
      }
    }

    if (payload is Iterable) {
      for (final element in payload) {
        final nested = _extractProfileMap(element);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return null;
  }

  bool _containsProfileKeys(Map<dynamic, dynamic> map) {
    const candidates = ['name', 'nama', 'email', 'email_address', 'phone'];
    for (final entry in map.entries) {
      final keyString = entry.key.toString().toLowerCase();
      if (entry.value is String &&
          candidates.any((candidate) => keyString.contains(candidate))) {
        return true;
      }
    }
    return false;
  }

  String? _resolveTokenFromPayload(dynamic payload) {
    if (payload == null) {
      return null;
    }

    if (payload is Map) {
      const tokenKeys = [
        'accessToken',
        'access_token',
        'token',
        'api_token',
        'bearer_token',
      ];

      for (final key in tokenKeys) {
        final value = payload[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }

      for (final value in payload.values) {
        if (value is Map || value is Iterable) {
          final nestedToken = _resolveTokenFromPayload(value);
          if (nestedToken != null && nestedToken.isNotEmpty) {
            return nestedToken;
          }
        }
      }
    }

    if (payload is Iterable) {
      for (final element in payload) {
        final nested = _resolveTokenFromPayload(element);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return null;
  }
}
