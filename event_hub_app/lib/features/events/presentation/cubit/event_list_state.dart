import 'package:event_hub_app/features/events/domain/entities/event.dart';

sealed class EventListState {
  const EventListState();
}

final class EventListInitial extends EventListState {
  const EventListInitial();
}

final class EventListLoading extends EventListState {
  const EventListLoading();
}

final class EventListLoaded extends EventListState {
  const EventListLoaded(this.events);

  final List<Event> events;
}

final class EventListError extends EventListState {
  const EventListError(this.message);

  final String message;
}
