import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:event_hub_app/features/events/data/models/comment_with_user_model.dart';
import 'package:event_hub_app/features/events/data/models/event_detail_model.dart';
import 'package:event_hub_app/features/events/data/models/event_model.dart';
import 'package:event_hub_app/features/events/data/models/poll_model.dart';
import 'package:event_hub_app/features/events/data/models/poll_option_model.dart';
import 'package:event_hub_app/features/events/domain/entities/event.dart';
import 'package:event_hub_app/features/events/domain/entities/poll.dart';
import 'package:event_hub_app/features/events/domain/entities/poll_option.dart';

class EventRemoteService {
  static const String baseUrl = 'http://localhost:8080/api';

  // TODO: Replace with real auth when implemented.
  static const String currentUserId = 'fb59cd2a-d947-4759-80d3-4a80d7ec71b6';

  final http.Client _client;

  EventRemoteService({http.Client? client}) : _client = client ?? http.Client();

  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      final message = body is Map<String, dynamic>
          ? body['error'] ?? body['message'] ?? 'Unknown error'
          : 'Unknown error';
      throw Exception(message);
    }
    return body;
  }

  Future<List<Event>> getEvents({String? status, String? category}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (category != null) queryParams['category'] = category;

    final uri = Uri.parse(
      '$baseUrl/events',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final response = await _client.get(uri);
    final body = _handleResponse(response) as List<dynamic>;
    return body
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EventDetailModel> getEventDetail(String eventId) async {
    final response = await _client.get(Uri.parse('$baseUrl/events/$eventId'));
    final body = _handleResponse(response) as Map<String, dynamic>;
    return EventDetailModel.fromJson(body);
  }

  Future<Event> createEvent({
    required String title,
    required String description,
    required String type,
    required String category,
    required String creatorId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/events'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'type': type,
        'category': category,
        'creatorId': creatorId,
      }),
    );
    final body = _handleResponse(response) as Map<String, dynamic>;
    return EventModel.fromJson(body);
  }

  Future<({bool voted, int upvotes})> voteEvent(
    String eventId,
    String userId,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/events/$eventId/vote'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    final body = _handleResponse(response) as Map<String, dynamic>;
    return (voted: body['voted'] as bool, upvotes: body['upvotes'] as int);
  }

  Future<Poll> createPoll({
    required String eventId,
    required String question,
    required String type,
    required List<String> options,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/events/$eventId/polls'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': question,
        'type': type,
        'options': options,
      }),
    );
    final body = _handleResponse(response) as Map<String, dynamic>;
    return PollModel.fromJson(body, eventId: eventId);
  }

  Future<({List<PollOption> options, List<String> userVotes})> votePoll({
    required String pollId,
    required String optionId,
    required String userId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/polls/$pollId/vote'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'optionId': optionId}),
    );
    final body = _handleResponse(response) as Map<String, dynamic>;
    final options = (body['options'] as List<dynamic>)
        .map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final userVotes = (body['userVotes'] as List<dynamic>)
        .map((e) => e as String)
        .toList();
    return (options: options, userVotes: userVotes);
  }

  Future<({bool participating, String? status, Map<String, int> counts})>
  participate({
    required String eventId,
    required String userId,
    required String status,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/events/$eventId/participate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'status': status}),
    );
    final body = _handleResponse(response) as Map<String, dynamic>;
    final rawCounts = body['counts'] as Map<String, dynamic>?;
    final counts = rawCounts?.map(
          (key, value) => MapEntry(key, value as int),
        ) ??
        {'going': 0, 'maybe': 0, 'notGoing': 0};
    return (
      participating: body['participating'] as bool,
      status: body['status'] as String?,
      counts: counts,
    );
  }

  Future<CommentWithUserModel> addComment({
    required String eventId,
    required String userId,
    required String content,
    String? parentId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/events/$eventId/comments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'content': content,
        if (parentId != null) 'parentId': parentId,
      }),
    );
    final body = _handleResponse(response) as Map<String, dynamic>;
    return CommentWithUserModel.fromJson(body, eventId: eventId);
  }

  Future<({bool voted, int upvotes})> voteComment(
    String commentId,
    String userId,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/comments/$commentId/vote'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    final body = _handleResponse(response) as Map<String, dynamic>;
    return (voted: body['voted'] as bool, upvotes: body['upvotes'] as int);
  }
}
