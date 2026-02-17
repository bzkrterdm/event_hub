import 'package:event_hub_app/features/events/domain/entities/event.dart';
import 'package:event_hub_app/features/events/domain/enums/event_category.dart';
import 'package:event_hub_app/features/events/domain/enums/event_status.dart';
import 'package:event_hub_app/features/events/domain/enums/event_type.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.status,
    required super.category,
    required super.creatorId,
    required super.upvotes,
    required super.commentCount,
    required super.createdAt,
    super.finalizedAt,
    super.finalDate,
    super.finalLocation,
    super.finalDetails,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: EventType.values.byName(json['type'] as String),
      status: EventStatus.values.byName(json['status'] as String),
      category: EventCategory.values.byName(json['category'] as String),
      creatorId: json['creator'] is Map<String, dynamic>
          ? (json['creator'] as Map<String, dynamic>)['id'] as String
          : json['creatorId'] as String,
      upvotes: json['upvotes'] as int,
      commentCount: json['commentCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      finalizedAt: json['finalizedAt'] != null
          ? DateTime.parse(json['finalizedAt'] as String)
          : null,
      finalDate: json['finalDate'] != null
          ? DateTime.parse(json['finalDate'] as String)
          : null,
      finalLocation: json['finalLocation'] as String?,
      finalDetails: json['finalDetails'] as String?,
    );
  }

  factory EventModel.fromDomain(Event event) {
    return EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      type: event.type,
      status: event.status,
      category: event.category,
      creatorId: event.creatorId,
      upvotes: event.upvotes,
      commentCount: event.commentCount,
      createdAt: event.createdAt,
      finalizedAt: event.finalizedAt,
      finalDate: event.finalDate,
      finalLocation: event.finalLocation,
      finalDetails: event.finalDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'category': category.name,
      'creatorId': creatorId,
      'upvotes': upvotes,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
      'finalizedAt': finalizedAt?.toIso8601String(),
      'finalDate': finalDate?.toIso8601String(),
      'finalLocation': finalLocation,
      'finalDetails': finalDetails,
    };
  }
}
