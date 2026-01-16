// local_storage_repository.dart
import 'package:pretty_logger/pretty_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepository {
  Future<void> setToken(String token) async {
    PLog.info('💾 Attempting to save token: $token');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool success = await sharedPreferences.setString('x-auth-token', token);
    PLog.info('💾 Token saved successfully: $success');
  }

  Future<String?> getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('x-auth-token');
    PLog.info('🔑 Retrieved token: $token');
    return token;
  }

  // Optional: Add method to clear token
  Future<void> clearToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove('x-auth-token');
  }
}