import 'package:send_sms/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalHelper {
  static Future<void> saveMessageTemplate(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(messageTemplateKey, value);
  }

  static Future<String> getMessageTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(messageTemplateKey) ?? '';
  }
}
