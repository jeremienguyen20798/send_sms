abstract class HomeEvent {}

class HomeInitialEvent extends HomeEvent {}

class GetCallLogsEvent extends HomeEvent {}

class SaveMessageTemplateEvent extends HomeEvent {
  final String? template;

  SaveMessageTemplateEvent({required this.template});
}
