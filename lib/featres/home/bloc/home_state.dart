import 'package:call_log/call_log.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitialState extends HomeState {}

class GrantedRequestPermissionState extends HomeState {}

class DeniedRequestPermissionState extends HomeState {}

class GetCallLogsState extends HomeState {
  final List<CallLogEntry> callLogs;

  GetCallLogsState({required this.callLogs});

  @override
  List<Object?> get props => [callLogs];
}

class InsertNewCallLogState extends HomeState {
  final CallLogEntry callLogEntry;

  InsertNewCallLogState({required this.callLogEntry});

  @override
  List<Object?> get props => [callLogEntry];
}