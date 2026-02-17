import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Dummy page: Finalized Event Details (Stitch screen).
/// UI only; no controller or repository.
class FinalizedEventDetailPage extends StatelessWidget {
  const FinalizedEventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalized Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Event ID: $eventId', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            const Text('Finalized event details placeholder.'),
          ],
        ),
      ),
    );
  }
}
