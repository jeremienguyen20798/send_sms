import 'package:flutter/material.dart';
import 'package:send_sms/shared/dialogs/message_template_dialog.dart';

class AppUtils {
  static Future<String?> showMessageTemplateDialog(BuildContext context) async {
    final message = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return MessageTemplateDialog();
      },
    );
    return message;
  }
}
