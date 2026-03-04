import 'dart:async';

import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:send_sms/constants/app_constants.dart';
import 'package:send_sms/home_page.dart';

@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) {
  debugPrint("Message received in background: ${message.body}");
  Gemini.instance
      .promptStream(parts: [Part.text('Write a story about a magic backpack')])
      .listen((value) {
        print(value?.output);
      });
}

@pragma("vm:entry-point")
FutureOr<void> backgroundCallback(Uri? data) async {
  Telephony.backgroundInstance.listenIncomingSms(
    onNewMessage: (message) {},
    onBackgroundMessage: backgroundMessageHandler,
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Gemini.init(apiKey: apiKey);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}
