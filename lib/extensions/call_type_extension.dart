import 'package:call_log/call_log.dart';

extension CallTypeExtension on CallType {
  String get nameGet {
    switch (this) {
      case CallType.incoming:
        return 'Cuộc gọi đến';
      case CallType.outgoing:
        return 'Cuộc gọi đi';
      case CallType.missed:
        return 'Cuộc gọi nhỡ';
      case CallType.rejected:
        return 'Cuộc gọi bị từ chối';
      case CallType.blocked:
        return 'Cuộc gọi bị chặn';
      default:
        return 'Không xác định';
    }
  }
}
