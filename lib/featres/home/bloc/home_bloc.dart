import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:send_sms/featres/home/bloc/home_event.dart';
import 'package:send_sms/featres/home/bloc/home_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_sms/helper/local_helper.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  List<CallLogEntry> callLogs = [];

  HomeBloc() : super(HomeInitialState()) {
    on<HomeInitialEvent>(_initial);
    on<GetCallLogsEvent>(_getCallLogs);
    on<SaveMessageTemplateEvent>(_saveMessageTemplate);
  }

  Future<void> _initial(
    HomeInitialEvent event,
    Emitter<HomeState> emitter,
  ) async {
    final result = await _requestPermisions();
    if (result) {
      emitter(GrantedRequestPermissionState());
    }
  }

  Future<bool> _requestPermisions() async {
    final status = await [
      Permission.photos,
      Permission.phone,
      Permission.sms,
    ].request();
    return status[Permission.photos]!.isGranted &&
        status[Permission.phone]!.isGranted &&
        status[Permission.sms]!.isGranted;
  }

  Future<void> _getCallLogs(
    GetCallLogsEvent event,
    Emitter<HomeState> emitter,
  ) async {
    Iterable<CallLogEntry> entries = await CallLog.query(
      type: CallType.outgoing,
      dateTimeFrom: DateTime.now().subtract(Duration(days: 1)),
      dateTimeTo: DateTime.now().add(Duration(days: 1)),
    );
    var callLogs = entries.toList();
    callLogs = callLogs
        .where((test) => test.name == null || test.name == "")
        .toList();
    emitter(GetCallLogsState(callLogs: callLogs));
  }

  void _saveMessageTemplate(
    SaveMessageTemplateEvent event,
    Emitter<HomeState> emitter,
  ) {
    final value = event.template;
    if (value != null) {
      LocalHelper.saveMessageTemplate(value);
    }
  }
}
