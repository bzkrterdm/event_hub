import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:event_hub_app/features/events/domain/repositories/event_repository.dart';
import 'package:event_hub_app/features/events/presentation/cubit/create_event_cubit.dart';
import 'package:event_hub_app/features/events/presentation/cubit/event_detail_cubit.dart';
import 'package:event_hub_app/features/events/presentation/pages/create_event_page.dart';
import 'package:event_hub_app/features/events/presentation/pages/event_detail_page.dart';
import 'package:event_hub_app/features/events/presentation/pages/event_hub_home_page.dart';
import 'package:event_hub_app/features/events/presentation/pages/finalized_event_detail_page.dart';

/// Route path constants for the app.
abstract final class AppRoutes {
  static const String home = '/';
  static const String eventDetail = '/event/:id';
  static const String eventDetailDiscussion = '/event/:id/discussion';
  static const String createEvent = '/event/create';
  static const String finalizedEventDetail = '/event/:id/finalized';

  static String eventDetailPath(String id) => '/event/$id';
  static String eventDetailDiscussionPath(String id) =>
      '/event/$id/discussion';
  static String finalizedEventDetailPath(String id) =>
      '/event/$id/finalized';
}

/// App router configuration.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (BuildContext context, GoRouterState state) =>
          const EventHubHomePage(),
    ),
    GoRoute(
      path: '/event/create',
      name: 'createEvent',
      builder: (BuildContext context, GoRouterState state) => BlocProvider(
        create: (context) => CreateEventCubit(
          eventRepository: context.read<EventRepository>(),
        ),
        child: const CreateEventPage(),
      ),
    ),
    GoRoute(
      path: '/event/:id',
      name: 'eventDetail',
      builder: (BuildContext context, GoRouterState state) {
        final String id = state.pathParameters['id'] ?? '';
        return BlocProvider(
          create: (context) => EventDetailCubit(
            eventRepository: context.read<EventRepository>(),
          ),
          child: EventDetailPage(eventId: id),
        );
      },
    ),
    GoRoute(
      path: '/event/:id/discussion',
      name: 'eventDetailDiscussion',
      builder: (BuildContext context, GoRouterState state) {
        final String id = state.pathParameters['id'] ?? '';
        return BlocProvider(
          create: (context) => EventDetailCubit(
            eventRepository: context.read<EventRepository>(),
          ),
          child: EventDetailPage(eventId: id),
        );
      },
    ),
    GoRoute(
      path: '/event/:id/finalized',
      name: 'finalizedEventDetail',
      builder: (BuildContext context, GoRouterState state) {
        final String id = state.pathParameters['id'] ?? '';
        return FinalizedEventDetailPage(eventId: id);
      },
    ),
  ],
);
