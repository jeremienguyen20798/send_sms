import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';

class PipCallLogList extends StatelessWidget {
  final List<CallLogEntry> callLogs;
  const PipCallLogList({super.key, required this.callLogs});

  @override
  Widget build(BuildContext context) {
    return callLogs.isNotEmpty
        ? ListView.builder(
            itemCount: callLogs.length,
            itemBuilder: (context, index) {
              final callLog = callLogs[index];
              return callLog.number != null ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(callLog.number!),
              ) : null;
            },
          )
        : const Center(child: Text('No contacts found.'));
  }
}
