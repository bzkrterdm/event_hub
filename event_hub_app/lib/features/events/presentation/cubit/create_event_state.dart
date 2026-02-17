import 'package:event_hub_app/features/events/domain/entities/event.dart';

sealed class CreateEventState {
  const CreateEventState();
}

final class CreateEventInitial extends CreateEventState {
  const CreateEventInitial();
}

final class CreateEventSubmitting extends CreateEventState {
  const CreateEventSubmitting();
}

final class CreateEventSuccess extends CreateEventState {
  const CreateEventSuccess(this.event);

  final Event event;
}

final class CreateEventError extends CreateEventState {
  const CreateEventError(this.message);

  final String message;
}
