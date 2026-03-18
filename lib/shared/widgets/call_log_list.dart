import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:send_sms/extensions/call_type_extension.dart';

class CallLogList extends StatelessWidget {
  final List<CallLogEntry> callLogs;
  const CallLogList({super.key, required this.callLogs});

  @override
  Widget build(BuildContext context) {
    return callLogs.isNotEmpty
        ? ListView.builder(
            itemCount: callLogs.length,
            itemBuilder: (context, index) {
              final callLog = callLogs[index];
              return ListTile(
                title: callLog.number != null ? Text(callLog.number!) : null,
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(Icons.person, color: Colors.black),
                ),
                subtitle: Text(
                  callLog.callType?.nameGet ?? 'Không xác định',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          )
        : const Center(child: Text('No contacts found.'));
  }
}
