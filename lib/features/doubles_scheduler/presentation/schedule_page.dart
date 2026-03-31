import 'package:flutter/material.dart';

import '../data/mock_log_store.dart';
import '../application/generators/simple_scheduler.dart';
import 'models/event_draft.dart';
import 'event_list_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, required this.draft});

  final EventDraft draft;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

enum _ScheduleMenuAction { edit, list }

class _SchedulePageState extends State<SchedulePage> {
  final SimpleScheduler _scheduler = const SimpleScheduler();

  // TODO: 再生成時の tie-break 用 int _generationSeed = 0;
  final int _currentRoundIndex = 0; // TODO: 対戦終了で更新
  int _totalPlannedRounds = 6; // TODO: 初期値は暫定
  bool _isAdopted = false;

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _roundKeys = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<SchedulerPlayer> _buildPlayersFromDraft() {
    return widget.draft.displayNames.asMap().entries.map((entry) {
      final index = entry.key;
      final displayName = entry.value;

      return SchedulerPlayer(
        inputOrder: index + 1,
        eventNumber: index + 1,
        displayName: displayName,
      );
    }).toList();
  }

  List<ScheduledRound> _generateSchedule() {
    final players = _buildPlayersFromDraft();

    return _scheduler.generate(
        players: players, courtCount: widget.draft.courts, rounds: _totalPlannedRounds);
  }

  void _regenerate() {
    setState(() {
      // TODO: 再生成時の tie-break 用_generationSeed += 1;
      _isAdopted = false;
    });
  }

  void _addRound() {
    setState(() {
      _totalPlannedRounds += 1;
    });
  }

  void _saveCurrentPlan() {
    if (_isAdopted) return;

    // TODO: draft だけでなく採用対戦表も保存する
    MockLogStore.save(widget.draft);

    setState(() {
      _isAdopted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('この案を採用してログに保存しました'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _scrollToCurrentRound() {
    if (_currentRoundIndex < 0 || _currentRoundIndex >= _roundKeys.length) {
      return;
    }

    final targetContext = _roundKeys[_currentRoundIndex].currentContext;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  void _handleMenu(_ScheduleMenuAction action) {
    switch (action) {
      case _ScheduleMenuAction.edit:
        // TODO: EventSetupPage の初期値復元対応後に編集導線を再接続する initialDraft対応
        break;
      case _ScheduleMenuAction.list:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EventListPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    late final List<ScheduledRound> rounds;
    String? scheduleError;

    try {
      rounds = _generateSchedule();
    } catch (e) {
      rounds = [];
      scheduleError = e.toString();
    }

    if (_roundKeys.length != rounds.length) {
      _roundKeys
        ..clear()
        ..addAll(List.generate(rounds.length, (_) => GlobalKey()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.draft.eventName),
        actions: [
          PopupMenuButton<_ScheduleMenuAction>(
            onSelected: _handleMenu,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _ScheduleMenuAction.edit,
                child: Text('このイベントを編集'),
              ),
              PopupMenuItem(
                value: _ScheduleMenuAction.list,
                child: Text('対戦表一覧'),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _scrollToCurrentRound,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Text(
                        '面数: ${widget.draft.courts}   '
                        '人数: ${widget.draft.players}   '
                        '進行: ${_currentRoundIndex + 1}/$_totalPlannedRounds試合',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isAdopted) ...[
                  FilledButton.icon(
                    onPressed: _saveCurrentPlan,
                    icon: const Icon(Icons.save),
                    label: const Text('採用'),
                  ),
                  const SizedBox(width: 8),
                ],
                FilledButton(
                  onPressed: _addRound,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: scheduleError != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '対戦表生成エラー\n$scheduleError',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _ScheduleSummaryCard(draft: widget.draft),
                  const SizedBox(height: 12),
                  _SchedulePlayersCard(displayNames: widget.draft.displayNames),
                  const SizedBox(height: 12),
                  ...List.generate(rounds.length, (index) {
                    final round = rounds[index];
                    return _RoundCard(
                      key: _roundKeys[index],
                      round: round,
                      isCurrentRound: index == _currentRoundIndex,
                    );
                  }),
                  const SizedBox(height: 80),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _regenerate,
        icon: const Icon(Icons.refresh),
        label: const Text('さらに生成'),
      ),
    );
  }
}

class _ScheduleSummaryCard extends StatelessWidget {
  const _ScheduleSummaryCard({required this.draft});

  final EventDraft draft;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Text('イベント名: ${draft.eventName}'),
            Text('面数: ${draft.courts}'),
            Text('人数: ${draft.players}'),
          ],
        ),
      ),
    );
  }
}

class _SchedulePlayersCard extends StatelessWidget {
  const _SchedulePlayersCard({required this.displayNames});

  final List<String> displayNames;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: displayNames.asMap().entries.map((entry) {
            return Chip(
              label: Text('${entry.key + 1}: ${entry.value}'),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RoundCard extends StatelessWidget {
  const _RoundCard({
    super.key,
    required this.round,
    required this.isCurrentRound,
  });

  final ScheduledRound round;
  final bool isCurrentRound;

  @override
  Widget build(BuildContext context) {
    final cardColor = isCurrentRound ? Theme.of(context).colorScheme.primaryContainer : null;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '第${round.roundNumber}試合',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            ...round.courts.asMap().entries.map((entry) {
              final courtIndex = entry.key + 1;
              final court = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CourtMatchRow(
                  courtIndex: courtIndex,
                  roundNumber: round.roundNumber,
                  court: court,
                ),
              );
            }),
            const Divider(),
            Text(
              '休憩: ${round.restPlayers.map((p) => '${p.eventNumber}: ${p.displayName}').join(' / ')}',
            ),
          ],
        ),
      ),
    );
  }
}

class _CourtMatchRow extends StatelessWidget {
  const _CourtMatchRow({
    required this.courtIndex,
    required this.roundNumber,
    required this.court,
  });

  final int courtIndex;
  final int roundNumber;
  final ScheduledCourt court;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'コート$courtIndex',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${court.teamA[0].eventNumber}: ${court.teamA[0].displayName} / '
          '${court.teamA[1].eventNumber}: ${court.teamA[1].displayName}'
          '  vs  '
          '${court.teamB[0].eventNumber}: ${court.teamB[0].displayName} / '
          '${court.teamB[1].eventNumber}: ${court.teamB[1].displayName}',
        ),
        const SizedBox(height: 2),
        Text(
          '${court.teamA[0].eventNumber} / ${court.teamA[1].eventNumber}'
          '  vs  '
          '${court.teamB[0].eventNumber} / ${court.teamB[1].eventNumber}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
