import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  final _urlController = TextEditingController();
  final _courtsController = TextEditingController(text: '1');
  final _playersController = TextEditingController(text: '6');
  final _eventNameController = TextEditingController();

  final List<TextEditingController> _displayNameControllers = [];

  bool _isLoadingEvent = false;
  bool _showDetailInputs = false;

  int _courts = 1;

  int get _minPlayers => _courts * 4;
  int get _maxPlayers => (_courts * 4) + 10;

  @override
  void initState() {
    super.initState();
    _syncPlayersWithinRange(resetToDefault: true);
    _syncDisplayNameControllers();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _courtsController.dispose();
    _playersController.dispose();
    _eventNameController.dispose();

    for (final controller in _displayNameControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _syncCourtsController() {
    _courtsController.text = _courts.toString();
  }

  void _syncPlayersWithinRange({bool resetToDefault = false}) {
    final defaultPlayers = (_courts * 4) + 2;
    final current = int.tryParse(_playersController.text);

    int nextPlayers;
    if (resetToDefault || current == null) {
      nextPlayers = defaultPlayers;
    } else {
      nextPlayers = current.clamp(_minPlayers, _maxPlayers);
    }

    _playersController.text = nextPlayers.toString();
  }

  void _syncDisplayNameControllers() {
    final players = int.tryParse(_playersController.text) ?? _minPlayers;

    while (_displayNameControllers.length < players) {
      final index = _displayNameControllers.length + 1;
      _displayNameControllers.add(
        TextEditingController(text: '参加者$index'),
      );
    }

    while (_displayNameControllers.length > players) {
      _displayNameControllers.removeLast().dispose();
    }
  }

  void _setCourts(int value, {bool resetPlayersToDefault = false}) {
    final clamped = value.clamp(1, 10);
    setState(() {
      _courts = clamped;
      _syncCourtsController();
      _syncPlayersWithinRange(resetToDefault: resetPlayersToDefault);
      _syncDisplayNameControllers();
    });
  }

  void _setPlayers(int value) {
    final clamped = value.clamp(_minPlayers, _maxPlayers);
    setState(() {
      _playersController.text = clamped.toString();
      _syncDisplayNameControllers();
    });
  }

  void _decrementCourts() => _setCourts(_courts - 1, resetPlayersToDefault: true);
  void _incrementCourts() => _setCourts(_courts + 1, resetPlayersToDefault: true);

  void _decrementPlayers() {
    final current = int.tryParse(_playersController.text) ?? _minPlayers;
    _setPlayers(current - 1);
  }

  void _incrementPlayers() {
    final current = int.tryParse(_playersController.text) ?? _minPlayers;
    _setPlayers(current + 1);
  }

  Future<void> _fetchEventInfo() async {
    if (_isLoadingEvent) return;

    setState(() {
      _showDetailInputs = true;
      _isLoadingEvent = true;
    });

    final startedAt = DateTime.now();

    try {
      // TODO: URLからイベント情報を取得するAPI/パーサ処理に置き換える
      final mockFuture = Future<Map<String, dynamic>>.delayed(
        const Duration(milliseconds: 150),
        () => {
          'eventName': 'らんすけ公園庭球場 ${DateTime.now().toIso8601String()}',
          'courts': 1,
          'players': 6,
        },
      );

      final mockData = await mockFuture;

      final elapsed = DateTime.now().difference(startedAt);
      const minLoading = Duration(milliseconds: 500);
      if (elapsed < minLoading) {
        await Future.delayed(minLoading - elapsed);
      }

      if (!mounted) return;

      setState(() {
        _courts = (mockData['courts'] as int).clamp(1, 10);
        _syncCourtsController();

        final mockPlayers = mockData['players'] as int;
        _playersController.text = mockPlayers.clamp(_minPlayers, _maxPlayers).toString();

        _eventNameController.text = mockData['eventName'] as String;
        _syncDisplayNameControllers();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingEvent = false;
      });
    }
  }

  void _goNext() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _showDetailInputs = true;
      _syncDisplayNameControllers();
    });

    // TODO: 次Issueで EventDraft 作成 or 次画面遷移を実装
  }

  Widget _buildStepperField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required String tooltipDecrement,
    required String tooltipIncrement,
    required String? Function(String?) validator,
    required ValueChanged<String> onChanged,
  }) {
    return Expanded(
      child: Row(
        children: [
          IconButton(
            onPressed: _isLoadingEvent ? null : onDecrement,
            tooltip: tooltipDecrement,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Expanded(
            child: SizedBox(
              width: 96,
              child: TextFormField(
                controller: controller,
                enabled: !_isLoadingEvent,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                validator: validator,
                onChanged: onChanged,
              ),
            ),
          ),
          IconButton(
            onPressed: _isLoadingEvent ? null : onIncrement,
            tooltip: tooltipIncrement,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        TextFormField(
          controller: _eventNameController,
          enabled: !_isLoadingEvent,
          decoration: const InputDecoration(
            labelText: 'イベント名',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (!_showDetailInputs) return null;
            if ((value ?? '').trim().isEmpty) return 'イベント名を入力してください';
            return null;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '参加者表示名',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...List.generate(_displayNameControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              controller: _displayNameControllers[index],
              enabled: !_isLoadingEvent,
              decoration: InputDecoration(
                labelText: '参加者${index + 1}',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (!_showDetailInputs) return null;
                if ((value ?? '').trim().isEmpty) {
                  return '参加者${index + 1}の表示名を入力してください';
                }
                return null;
              },
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('テニス乱数表ジェネレーター'),
        actions: [
          IconButton(
            tooltip: '対戦表一覧',
            onPressed: () {
              // TODO: 対戦表一覧ページへ遷移
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: IgnorePointer(
                ignoring: _isLoadingEvent,
                child: Opacity(
                  opacity: _isLoadingEvent ? 0.5 : 1,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'URLを貼るか、手動で面数・人数を入力してください。',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _urlController,
                        enabled: !_isLoadingEvent,
                        decoration: const InputDecoration(
                          labelText: 'テニスベア / テニスオフ のイベントURL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: _fetchEventInfo,
                        child: const Text('イベント情報を取得する'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStepperField(
                            label: '面数',
                            controller: _courtsController,
                            onDecrement: _decrementCourts,
                            onIncrement: _incrementCourts,
                            tooltipDecrement: '面数を減らす',
                            tooltipIncrement: '面数を増やす',
                            validator: (value) {
                              final v = int.tryParse(value ?? '');
                              if (v == null) return '入力';
                              if (v < 1 || v > 10) return '1〜10';
                              return null;
                            },
                            onChanged: (value) {
                              final parsed = int.tryParse(value);
                              if (parsed == null) return;
                              _setCourts(parsed);
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildStepperField(
                            label: '人数',
                            controller: _playersController,
                            onDecrement: _decrementPlayers,
                            onIncrement: _incrementPlayers,
                            tooltipDecrement: '人数を減らす',
                            tooltipIncrement: '人数を増やす',
                            validator: (value) {
                              final v = int.tryParse(value ?? '');
                              if (v == null) return '入力';
                              if (v < _minPlayers || v > _maxPlayers) {
                                return '$_minPlayers〜$_maxPlayers';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              final parsed = int.tryParse(value);
                              if (parsed == null) return;
                              _setPlayers(parsed);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '人数は $_minPlayers 人以上、$_maxPlayers 人以下で入力してください。',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _goNext,
                        child: const Text('次へ'),
                      ),
                      if (_showDetailInputs) ...[
                        const SizedBox(height: 24),
                        _buildDetailSection(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoadingEvent)
              const Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('イベント情報を取得中...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
