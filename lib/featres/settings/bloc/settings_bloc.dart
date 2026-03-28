import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_sms/featres/settings/bloc/settings_event.dart';
import 'package:send_sms/featres/settings/bloc/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const platform = MethodChannel("com.example.send_sms/SendSMS");

  SettingsBloc() : super(InitialSettingsState()) {
    on<RequestDefaultSMSAppEvent>(_requestDefaultSMSApp);
  }

  Future<void> _requestDefaultSMSApp(
    RequestDefaultSMSAppEvent event,
    Emitter<SettingsState> emitter,
  ) async {
    try {
      await platform.invokeMethod('requestDefaultSMSApp');
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}
 