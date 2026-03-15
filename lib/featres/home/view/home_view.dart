import 'package:call_log/call_log.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:send_sms/featres/home/bloc/home_bloc.dart';
import 'package:send_sms/featres/home/bloc/home_event.dart';
import 'package:send_sms/featres/home/bloc/home_state.dart';
import 'package:send_sms/shared/widgets/call_log_list.dart';
import 'package:send_sms/shared/widgets/pip_call_log_list.dart';
import 'package:send_sms/utils/app_utils.dart';

List<CallLogEntry> callLogs = [];

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử cuộc gọi'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await AppUtils.showMessageTemplateDialog(context);
              // ignore: use_build_context_synchronously
              BlocProvider.of<HomeBloc>(
                context,
              ).add(SaveMessageTemplateEvent(template: result));
            },
            icon: Icon(Icons.edit_note),
          ),
        ],
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is GetCallLogsState) {
            callLogs = state.callLogs;
          } else if (state is InsertNewCallLogState) {
            final newCallLog = state.callLogEntry;
            callLogs.insert(0, newCallLog);
          }
          return PiPSwitcher(
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
          );
        },
        listener: (context, state) {
          if (state is GrantedRequestPermissionState) {
            BlocProvider.of<HomeBloc>(context).add(GetCallLogsEvent());
          } else if (state is DeniedRequestPermissionState) {
            openAppSettings();
          }
        },
      ),
    );
  }
}
