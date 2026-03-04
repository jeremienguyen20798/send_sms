import 'dart:math';

import 'package:another_telephony/telephony.dart';
import 'package:call_log/call_log.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:send_sms/shared/widget/call_log_list.dart';
import 'package:send_sms/constants/app_constants.dart';
import 'package:send_sms/shared/widget/pip_call_log_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CallLogEntry> callLogs = [];
  Telephony telephony = Telephony.instance;
  final floating = Floating();

  @override
  void initState() {
    _getCallLogs();
    _callStateListen();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _autoEnablePip();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử cuộc gọi'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.edit_note)),
        ],
      ),
      body: PiPSwitcher(
        childWhenEnabled: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [Expanded(child: PipCallLogList(callLogs: callLogs))],
        ),
        childWhenDisabled: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [Expanded(child: CallLogList(callLogs: callLogs))],
        ),
      ),
    );
  }

  Future<void> _getCallLogs() async {
    final status = await Permission.phone.request();
    if (status.isGranted) {
      Iterable<CallLogEntry> entries = await CallLog.query(
        type: CallType.outgoing,
        dateTimeFrom: DateTime.now().subtract(Duration(days: 1)),
        dateTimeTo: DateTime.now().add(Duration(days: 1)),
      );
      callLogs = entries.toList();
      callLogs = callLogs
          .where((test) => test.name == null || test.name == "")
          .toList();
      setState(() {});
    }
  }

  void _callStateListen() {
    Stream<PhoneState> phoneStateStream = PhoneState.stream;
    phoneStateStream.listen((snapshot) {
      final phoneStatus = snapshot.status;
      if (phoneStatus == PhoneStateStatus.CALL_ENDED) {
        final phoneNumber = snapshot.number;
        if (phoneNumber != null) {
          callLogs.insert(
            0,
            CallLogEntry(number: phoneNumber, callType: CallType.outgoing),
          );
          telephony.sendSms(
            to: phoneNumber,
            message: message,
            isMultipart: true,
            statusListener: (status) {
              debugPrint('SMS status: $status');
            },
          );
          setState(() {});
        }
      }
    });
  }

  Future<void> enablePip(
    BuildContext context, {
    bool autoEnable = false,
  }) async {
    final rational = Rational.landscape();
    final screenSize =
        MediaQuery.of(context).size * MediaQuery.of(context).devicePixelRatio;
    final height = screenSize.width ~/ rational.aspectRatio;
    final arguments = autoEnable
        ? OnLeavePiP(
            aspectRatio: rational,
            sourceRectHint: Rectangle<int>(
              0,
              (screenSize.height ~/ 2) - (height ~/ 2),
              screenSize.width.toInt(),
              height,
            ),
          )
        : ImmediatePiP(
            aspectRatio: rational,
            sourceRectHint: Rectangle<int>(
              0,
              (screenSize.height ~/ 2) - (height ~/ 2),
              screenSize.width.toInt(),
              height,
            ),
          );
    final status = await floating.enable(arguments);
    debugPrint('PIP enable: ${status.toString()}');
  }

  void _autoEnablePip() {
    enablePip(context, autoEnable: true);
  }
}
