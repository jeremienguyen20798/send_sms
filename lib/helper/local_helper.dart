import 'package:send_sms/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalHelper {
  static Future<void> saveEnablePip(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(enablePipKey, value);
  }

  static Future<bool> getEnablePip() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(enablePipKey) ?? false;
  }
}
