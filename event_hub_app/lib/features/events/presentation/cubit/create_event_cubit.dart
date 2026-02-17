import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:event_hub_app/features/events/domain/enums/event_category.dart';
import 'package:event_hub_app/features/events/domain/repositories/event_repository.dart';
import 'package:event_hub_app/features/events/presentation/cubit/create_event_state.dart';

class CreateEventCubit extends Cubit<CreateEventState> {
  CreateEventCubit({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const CreateEventInitial());

  final EventRepository _eventRepository;

  Future<void> createEvent({
    required String title,
    required EventCategory category,
    required String description,
    List<String>? pollOptions,
  }) async {
    emit(const CreateEventSubmitting());
    try {
      final event = await _eventRepository.createEvent(
        title: title,
        category: category,
        description: description,
        pollOptions: pollOptions,
      );
      emit(CreateEventSuccess(event));
    } on Exception catch (e) {
      emit(CreateEventError(e.toString()));
    }
  }
}
