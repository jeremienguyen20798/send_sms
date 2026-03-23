import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_sms/constants/app_constants.dart';
import 'package:send_sms/featres/home/bloc/home_bloc.dart';
import 'package:send_sms/featres/home/bloc/home_event.dart';
import 'package:send_sms/featres/home/bloc/home_state.dart';
import 'package:send_sms/featres/settings/view/settings_page.dart';
import 'package:send_sms/shared/widgets/call_log_list.dart';
import 'package:send_sms/utils/app_formatter.dart';
import 'package:send_sms/utils/app_utils.dart';

List<CallLogEntry> callLogs = [];

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ListTile(
          minLeadingWidth: 0.0,
          contentPadding: EdgeInsets.zero,
          title: Text(
            appTitle,
            maxLines: 1,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: Text(
            'Hôm nay, ngày ${AppFormatter.formatDateTime(DateTime.now())}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
            icon: Icon(Icons.more_vert),
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [Expanded(child: CallLogList(callLogs: callLogs))],
          );
        },
        listener: (context, state) {
          if (state is GrantedRequestPermissionState) {
            BlocProvider.of<HomeBloc>(context).add(GetCallLogsEvent());
          } else if (state is DeniedRequestPermissionState) {
            AppUtils.showWarningDialog(context);
          }
        },
      ),
    );
  }
}
