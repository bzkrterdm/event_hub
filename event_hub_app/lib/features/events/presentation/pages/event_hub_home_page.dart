import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:event_hub_app/core/router/app_router.dart';
import 'package:event_hub_app/features/events/presentation/cubit/event_list_cubit.dart';
import 'package:event_hub_app/features/events/presentation/cubit/event_list_state.dart';
import 'package:event_hub_app/features/events/presentation/widgets/event_card.dart';

class EventHubHomePage extends StatefulWidget {
  const EventHubHomePage({super.key});

  @override
  State<EventHubHomePage> createState() => _EventHubHomePageState();
}

class _EventHubHomePageState extends State<EventHubHomePage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<EventListCubit>();
    Future.microtask(cubit.loadEvents);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Hub')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createEvent),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<EventListCubit, EventListState>(
        builder: (context, state) {
          return switch (state) {
            EventListInitial() ||
            EventListLoading() =>
              const Center(child: CircularProgressIndicator()),
            EventListError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          context.read<EventListCubit>().loadEvents(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            EventListLoaded(:final events) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final event = events[index];
                  return EventCard(
                    event: event,
                    onTap: () => context.push(
                      AppRoutes.eventDetailPath(event.id),
                    ),
                  );
                },
              ),
          };
        },
      ),
    );
  }
}
