abstract class HomeEvent {}

class HomeInitialEvent extends HomeEvent {}

class GetCallLogsEvent extends HomeEvent {}

class SaveMessageTemplateEvent extends HomeEvent {
  final String? template;

  SaveMessageTemplateEvent({required this.template});
}

class CallStateListenEvent extends HomeEvent {}

class InsertNewCallLogEvent extends HomeEvent {
  final String phoneNumber;

  InsertNewCallLogEvent({required this.phoneNumber});
}
