import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:event_hub_app/features/events/domain/repositories/event_repository.dart';
import 'package:event_hub_app/features/events/presentation/cubit/event_list_state.dart';

class EventListCubit extends Cubit<EventListState> {
  EventListCubit({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const EventListInitial());

  final EventRepository _eventRepository;

  Future<void> loadEvents({String? status, String? category}) async {
    emit(const EventListLoading());
    try {
      final events = await _eventRepository.getEvents(
        status: status,
        category: category,
      );
      emit(EventListLoaded(events));
    } on Exception catch (e) {
      emit(EventListError(e.toString()));
    }
  }
}
