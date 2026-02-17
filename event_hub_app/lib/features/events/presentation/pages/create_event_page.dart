import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:event_hub_app/features/events/domain/enums/event_category.dart';
import 'package:event_hub_app/features/events/presentation/cubit/create_event_cubit.dart';
import 'package:event_hub_app/features/events/presentation/cubit/create_event_state.dart';
import 'package:event_hub_app/features/events/presentation/cubit/event_list_cubit.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pollOption1Controller = TextEditingController();
  final _pollOption2Controller = TextEditingController();

  EventCategory? _selectedCategory;
  bool _addPoll = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pollOption1Controller.dispose();
    _pollOption2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<CreateEventCubit, CreateEventState>(
      listener: (context, state) {
        switch (state) {
          case CreateEventSuccess():
            context.read<EventListCubit>().loadEvents();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event created successfully!')),
            );
            context.pop();
          case CreateEventError(:final message):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create event: $message')),
            );
          case _:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Event Hub'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(textTheme),
                  const SizedBox(height: 32),
                  _buildFormCard(colorScheme, textTheme),
                  const SizedBox(height: 24),
                  _buildCancelLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Column(
      children: [
        Text(
          'Create New Event',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Fill in the details below to schedule your team event.',
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleField(textTheme),
              const SizedBox(height: 20),
              _buildCategoryDropdown(textTheme),
              const SizedBox(height: 20),
              _buildDescriptionField(textTheme),
              const SizedBox(height: 20),
              _buildPollSection(textTheme),
              const SizedBox(height: 32),
              _buildCreateButton(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Title',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g., Friday Team Lunch',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an event title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<EventCategory>(
          initialValue: _selectedCategory,
          hint: Text(
            'Select a category...',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: EventCategory.values.map((category) {
            return DropdownMenuItem<EventCategory>(
              value: category,
              child: Text(_categoryDisplayName(category)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value),
          validator: (value) {
            if (value == null) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'What is this event about?',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPollSection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _addPoll,
                onChanged: (value) => setState(() => _addPoll = value ?? false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add a Poll',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ask a question with two options.',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_addPoll) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Option 1',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pollOption1Controller,
                  decoration: InputDecoration(
                    hintText: 'Yes / Option A',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  style: textTheme.bodySmall,
                  validator: (value) {
                    if (_addPoll &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please enter option 1';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Option 2',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pollOption2Controller,
                  decoration: InputDecoration(
                    hintText: 'No / Option B',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  style: textTheme.bodySmall,
                  validator: (value) {
                    if (_addPoll &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please enter option 2';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCreateButton(ColorScheme colorScheme) {
    return BlocBuilder<CreateEventCubit, CreateEventState>(
      builder: (context, state) {
        final isSubmitting = state is CreateEventSubmitting;

        return SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: isSubmitting ? null : _onCreatePressed,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Create Event',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
          ),
        );
      },
    );
  }

  void _onCreatePressed() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final pollOptions = _addPoll
        ? [
            _pollOption1Controller.text.trim(),
            _pollOption2Controller.text.trim(),
          ]
        : null;

    context.read<CreateEventCubit>().createEvent(
          title: _titleController.text.trim(),
          category: _selectedCategory!,
          description: _descriptionController.text.trim(),
          pollOptions: pollOptions,
        );
  }

  Widget _buildCancelLink(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => context.pop(),
        child: Text(
          'Cancel and go back',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Helpers

  String _categoryDisplayName(EventCategory category) {
    return switch (category) {
      EventCategory.cinema => 'Cinema',
      EventCategory.food => 'Food',
      EventCategory.games => 'Games',
      EventCategory.sports => 'Sports',
      EventCategory.other => 'Other',
    };
  }
}
