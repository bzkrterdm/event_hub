// Basic Flutter widget test for Event Hub app.

import 'package:flutter_test/flutter_test.dart';

import 'package:event_hub_app/features/events/data/datasources/event_remote_service.dart';
import 'package:event_hub_app/features/events/data/repositories/event_repository_impl.dart';
import 'package:event_hub_app/main.dart';

void main() {
  testWidgets('Event Hub app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      EventHubApp(
        eventRepository: EventRepositoryImpl(
          remoteService: EventRemoteService(),
        ),
      ),
    );

    expect(find.text('Event Hub'), findsOneWidget);
  });
}
