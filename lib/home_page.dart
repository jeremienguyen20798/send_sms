import 'dart:math';

import 'package:another_telephony/telephony.dart';
import 'package:call_log/call_log.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:send_sms/helper/local_helper.dart';
import 'package:send_sms/shared/widgets/call_log_list.dart';
import 'package:send_sms/shared/widgets/pip_call_log_list.dart';
import 'package:send_sms/utils/app_utils.dart';

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
          IconButton(
            onPressed: () async {
              final result = await AppUtils.showMessageTemplateDialog(context);
              _saveMessageTemplate(result);
            },
            icon: Icon(Icons.edit_note),
          ),
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
    phoneStateStream.listen((snapshot) async {
      final phoneStatus = snapshot.status;
      if (phoneStatus == PhoneStateStatus.CALL_ENDED) {
        final phoneNumber = snapshot.number;
        if (phoneNumber != null) {
          callLogs.insert(
            0,
            CallLogEntry(number: phoneNumber, callType: CallType.outgoing),
          );
          final message = await LocalHelper.getMessageTemplate();
          if (message.isNotEmpty) {
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

  void _saveMessageTemplate(String? value) {
    if (value != null) {
      LocalHelper.saveMessageTemplate(value);
    }
  }
}
