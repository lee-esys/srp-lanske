import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _playersController = TextEditingController(text: '6');

  int _courts = 1;

  @override
  void dispose() {
    _urlController.dispose();
    _playersController.dispose();
    super.dispose();
  }

  void _setPlayersFromCourts() {
    _playersController.text = ((_courts * 4) + 2).toString();
  }

  void _decrementPlayers() {
    final current = int.tryParse(_playersController.text) ?? (_courts * 4);
    final minPlayers = _courts * 4;

    if (current > minPlayers) {
      setState(() {
        _playersController.text = (current - 1).toString();
      });
    }
  }

  void _incrementPlayers() {
    final current = int.tryParse(_playersController.text) ?? 4;
    setState(() {
      _playersController.text = (current + 1).toString();
    });
  }

  void _goNext() {
    if (!_formKey.currentState!.validate()) return;

    final players = int.parse(_playersController.text);
    // TODO: EventSetupPageに変更する => まずはEventDraftを作るところまで。EventDraftはEventSetupPageの引数で渡す
    // final draft = EventDraft(
    //   url: _urlController.text.trim(),
    //   courts: _courts,
    //   players: players,
    //   eventName: _urlController.text.trim().isNotEmpty ? 'テニスベアイベント' : '新規イベント',
    //   displayNames: List.generate(players, (i) => '参加者${i + 1}'),
    // );

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => EventSetupScreen(initialDraft: draft)),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('テニス乱数表ジェネレーター'),
        actions: [
          IconButton(
            tooltip: 'ログ', // TODO: ログではなく対戦表一覧。アイコンも変える
            onPressed: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (_) => const LogListScreen()),
              //   );
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                decoration: const InputDecoration(
                  labelText: 'テニスベアのイベントURL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _courts,
                decoration: const InputDecoration(
                  labelText: '面数',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  8,
                  (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1} 面')),
                ),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _courts = value;
                    _setPlayersFromCourts();
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: _decrementPlayers,
                    icon: const Icon(Icons.remove_circle_outline),
                    tooltip: '人数を減らす',
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _playersController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '人数',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final v = int.tryParse(value ?? '');
                        if (v == null) return '人数を入力してください';
                        if (v < 4) return '4人以上を入力してください';
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: _incrementPlayers,
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: '人数を増やす',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _goNext, child: const Text('次へ')),
            ],
          ),
        ),
      ),
    );
  }
}
