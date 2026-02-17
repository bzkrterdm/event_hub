class PollOption {
  const PollOption({
    required this.id,
    required this.text,
    required this.voteCount,
  });

  final String id;
  final String text;
  final int voteCount;

  PollOption copyWith({String? id, String? text, int? voteCount}) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      voteCount: voteCount ?? this.voteCount,
    );
  }
}
