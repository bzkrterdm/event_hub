import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:event_hub_app/core/router/app_router.dart';
import 'package:event_hub_app/features/events/data/datasources/event_remote_service.dart';
import 'package:event_hub_app/features/events/data/repositories/event_repository_impl.dart';
import 'package:event_hub_app/features/events/domain/repositories/event_repository.dart';
import 'package:event_hub_app/features/events/presentation/cubit/event_list_cubit.dart';

void main() {
  final remoteService = EventRemoteService();
  final EventRepository eventRepository =
      EventRepositoryImpl(remoteService: remoteService);

  runApp(EventHubApp(eventRepository: eventRepository));
}

class EventHubApp extends StatelessWidget {
  const EventHubApp({super.key, required this.eventRepository});

  final EventRepository eventRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<EventRepository>.value(
      value: eventRepository,
      child: BlocProvider(
        create: (_) => EventListCubit(eventRepository: eventRepository),
        child: MaterialApp.router(
          title: 'Event Hub',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
