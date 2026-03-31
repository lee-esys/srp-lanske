class EventDraft {
  EventDraft({
    required this.url,
    required this.courts,
    required this.players,
    required this.eventName,
    required this.displayNames,
  });

  final String url;
  final int courts;
  final int players;
  final String eventName;
  final List<String> displayNames;

  EventDraft copyWith({
    String? url,
    int? courts,
    int? players,
    String? eventName,
    List<String>? displayNames,
  }) {
    return EventDraft(
      url: url ?? this.url,
      courts: courts ?? this.courts,
      players: players ?? this.players,
      eventName: eventName ?? this.eventName,
      displayNames: displayNames ?? List<String>.from(this.displayNames),
    );
  }
}
