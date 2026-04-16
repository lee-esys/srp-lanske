import 'dart:convert';

import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class ParticipantDraft {
  ParticipantDraft({
    required this.id,
    required this.displayName,
  });

  factory ParticipantDraft.create({
    required String displayName,
  }) {
    return ParticipantDraft(
      id: _uuid.v4(),
      displayName: displayName,
    );
  }

  final String id;
  final String displayName;

  ParticipantDraft copyWith({
    String? id,
    String? displayName,
  }) {
    return ParticipantDraft(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
