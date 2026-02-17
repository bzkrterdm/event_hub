import 'package:event_hub_app/features/events/domain/enums/event_category.dart';
import 'package:event_hub_app/features/events/domain/enums/event_status.dart';
import 'package:event_hub_app/features/events/domain/enums/event_type.dart';

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.category,
    required this.creatorId,
    required this.upvotes,
    required this.commentCount,
    required this.createdAt,
    this.finalizedAt,
    this.finalDate,
    this.finalLocation,
    this.finalDetails,
  });

  final String id;
  final String title;
  final String description;
  final EventType type;
  final EventStatus status;
  final EventCategory category;
  final String creatorId;
  final int upvotes;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? finalizedAt;
  final DateTime? finalDate;
  final String? finalLocation;
  final String? finalDetails;

  Event copyWith({
    String? id,
    String? title,
    String? description,
    EventType? type,
    EventStatus? status,
    EventCategory? category,
    String? creatorId,
    int? upvotes,
    int? commentCount,
    DateTime? createdAt,
    Object? finalizedAt = _sentinel,
    Object? finalDate = _sentinel,
    Object? finalLocation = _sentinel,
    Object? finalDetails = _sentinel,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      category: category ?? this.category,
      creatorId: creatorId ?? this.creatorId,
      upvotes: upvotes ?? this.upvotes,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      finalizedAt: finalizedAt == _sentinel
          ? this.finalizedAt
          : finalizedAt as DateTime?,
      finalDate: finalDate == _sentinel
          ? this.finalDate
          : finalDate as DateTime?,
      finalLocation: finalLocation == _sentinel
          ? this.finalLocation
          : finalLocation as String?,
      finalDetails: finalDetails == _sentinel
          ? this.finalDetails
          : finalDetails as String?,
    );
  }

  static const _sentinel = Object();
}
