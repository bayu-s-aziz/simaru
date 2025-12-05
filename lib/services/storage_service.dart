import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  StorageService() : _box = GetStorage();

  final GetStorage _box;

  static const _tokenKey = 'auth_token';
  static const _profileKey = 'user_profile';
  static const _nameKey = 'user_name';

  Future<void> saveAuthData({
    String? token,
    Map<String, dynamic>? profile,
    String? name,
  }) async {
    if (token != null && token.trim().isNotEmpty) {
      await _box.write(_tokenKey, token.trim());
    } else if (token == null) {
      await _box.remove(_tokenKey);
    }

    if (profile != null && profile.isNotEmpty) {
      await _box.write(_profileKey, profile);
    } else if (profile == null) {
      await _box.remove(_profileKey);
    }

    if (name != null && name.trim().isNotEmpty) {
      await _box.write(_nameKey, name.trim());
    } else if (name == null) {
      await _box.remove(_nameKey);
    }
  }

  String? readToken() => _box.read<String>(_tokenKey);

  Map<String, dynamic>? readProfile() {
    final stored = _box.read(_profileKey);
    if (stored is Map) {
      return Map<String, dynamic>.from(stored);
    }
    return null;
  }

  String? readUserName() => _box.read<String>(_nameKey);

  Future<void> clearAuth() async {
    await _box.remove(_tokenKey);
    await _box.remove(_profileKey);
    await _box.remove(_nameKey);
  }
}