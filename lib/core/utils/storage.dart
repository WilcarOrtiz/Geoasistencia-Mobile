import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    if (_prefs == null) {
      throw Exception("StorageService not initialized");
    }
    return _prefs!;
  }

  static Future<void> saveToken(String token) async {
    await _p.setString('token', token);
  }

  static String? getToken() => _p.getString('token');

  static Future<void> saveData(String key, String value) async {
    await _p.setString(key, value);
  }

  static String? getData(String key) => _p.getString(key);

  static Future<void> clear() async {
    await _p.clear();
  }
}
