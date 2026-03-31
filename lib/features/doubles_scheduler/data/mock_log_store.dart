import '../presentation/models/event_draft.dart';

class SavedEvent {
  SavedEvent({required this.id, required this.savedAt, required this.draft});

  final String id;
  final DateTime savedAt;
  final EventDraft draft;
}

class MockLogStore {
  static final List<SavedEvent> _items = [];

  static List<SavedEvent> get items => List.unmodifiable(_items.reversed);

  static void save(EventDraft draft) {
    final copiedDraft = draft.copyWith(
      displayNames: List<String>.from(draft.displayNames),
    );

    _items.add(
      SavedEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        savedAt: DateTime.now(),
        draft: copiedDraft,
      ),
    );
  }
}
