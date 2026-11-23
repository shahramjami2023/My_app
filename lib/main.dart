import "dart:async";
import "dart:math";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: StickmanPartyMenu(),
    ),
  ));
}

class PlayerInfo {
  final int id;
  final String name;
  final Color color;
  final LogicalKeyboardKey key;
  final String keyLabel;
  int score;

  PlayerInfo({
    required this.id,
    required this.name,
    required this.color,
    required this.key,
    required this.keyLabel,
    this.score = 0,
  });
}

class StickmanPartyMenu extends StatefulWidget {
  const StickmanPartyMenu({super.key});

  @override
  State<StickmanPartyMenu> createState() => _StickmanPartyMenuState();
}

class _StickmanPartyMenuState extends State<StickmanPartyMenu> {
  int _playerCount = 2;

  final List<PlayerInfo> _players = [
    PlayerInfo(id: 0, name: "قرمز", color: Colors.red, key: LogicalKeyboardKey.keyW, keyLabel: "W"),
    PlayerInfo(id: 1, name: "آبی", color: Colors.blue, key: LogicalKeyboardKey.arrowUp, keyLabel: "↑"),
    PlayerInfo(id: 2, name: "سبز", color: Colors.green, key: LogicalKeyboardKey.keyA, keyLabel: "A"),
    PlayerInfo(id: 3, name: "زرد", color: Colors.orange, key: LogicalKeyboardKey.keyL, keyLabel: "L"),
  ];

  void _startGame(int gameIndex) {
    final activePlayers = _players.take(_playerCount).toList();
    Widget gameScreen;
    if (gameIndex == 0) {
      gameScreen = TugOfWarGame(players: activePlayers);
    } else if (gameIndex == 1) {
      gameScreen = TankBattleGame(players: activePlayers);
    } else {
      gameScreen = QuickDrawGame(players: activePlayers);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Directionality(textDirection: TextDirection.rtl, child: gameScreen),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final counts = List.generate(3, (i) => i + 2);
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("پارتی آدمک‌ها (۲ تا ۴ نفره)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "صفر کردن امتیازها",
            onPressed: () {
              setState(() {
                for (var p in _players) {
                  p.score = 0;
                }
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _players.take(_playerCount).map((p) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: p.color,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text("بازیکن ${p.name}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("${p.score} 🏆", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text("تعداد بازیکنان را انتخاب کنید:", style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: counts.map((count) {
                final selected = _playerCount == count;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    selected: selected,
                    selectedColor: Colors.amber,
                    label: Text(
                      "$count نفره",
                      style: TextStyle(
                        color: selected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    backgroundColor: Colors.white12,
                    onSelected: (_) => setState(() => _playerCount = count),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _gameCard(
                    title: "۱. مسابقه سرعت و طناب‌کشی 🏃",
                    subtitle: "هر کس سریع‌تر دکمه‌اش را بزند آدمکش به خط پایان می‌رسد!",
                    color: Colors.teal,
                    onTap: () => _startGame(0),
                  ),
                  _gameCard(
                    title: "۲. نبرد تانک‌ها در میدان 💥",
                    subtitle: "تانک‌ها می‌چرخند؛ با شلیک دقیق بقیه را حذف کن!",
                    color: Colors.deepOrange,
                    onTap: () => _startGame(1),
                  ),
                  _gameCard(
                    title: "۳. واکنش سریع (سبز شد بزن!) ⚡",
                    subtitle: "تا صفحه سبز نشده نزن! سریع‌ترین انگشت برنده است.",
                    color: Colors.indigo,
                    onTap: () => _startGame(2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gameCard({required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ),
        trailing: const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
        onTap: onTap,
      ),
    );
  }
}

class TugOfWarGame extends StatefulWidget {
  final List<PlayerInfo> players;
  const TugOfWarGame({super.key, required this.players});

  @override
  State<TugOfWarGame> createState() => _TugOfWarGameState();
}

class _TugOfWarGameState extends State<TugOfWarGame> {
  late List<double> _progress;
  PlayerInfo? _winner;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _progress = List.filled(widget.players.length, 0.0);
  }

  void _tapPlayer(int index) {
    if (_winner != null) return;
    setState(() {
      _progress[index] += 0.05;
      if (_progress[index] >= 1.0) {
        _progress[index] = 1.0;
        _winner = widget.players[index];
        _winner!.score += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          for (int i = 0; i < widget.players.length; i++) {
            if (event.logicalKey == widget.players[i].key) {
              _tapPlayer(i);
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(title: const Text("مسابقه سرعت آدمک‌ها"), backgroundColor: Colors.teal),
        body: Column(
          children: [
            if (_winner != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: _winner!.color,
                child: Column(
                  children: [
                    Text("🎉 بازیکن ${_winner!.name} برنده شد! 🎉",
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("بازگشت به منوی بازی‌ها"),
                    )
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(widget.players.length, (i) {
                    final p = widget.players[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("آدمک ${p.name}", style: TextStyle(color: p.color, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Stack(
                          children: [
                            Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: _progress[i].clamp(0.08, 1.0),
                              child: Container(
Use code with caution.
height: 36,
decoration: BoxDecoration(
color: p.color,
borderRadius: BorderRadius.circular(18),
),
alignment: Alignment.centerLeft,
padding: const EdgeInsets.symmetric(horizontal: 8),
child: const Text("🏃", style: TextStyle(fontSize: 22)),
),
),
],
),
],
);
}),
),
),
),
_PlayerControlPad(players: widget.players, onPlayerAction: _tapPlayer, buttonText: "بزن!"),
],
),
),
);
}
}
class _Tank {
double x;
double y;
double angle;
bool alive;
_Tank({required this.x, required this.y, required this.angle, this.alive = true});
}
class _Bullet {
double x;
double y;
double dx;
double dy;
int ownerIndex;
_Bullet({required this.x, required this.y, required this.dx, required this.dy, required this.ownerIndex});
}
class TankBattleGame extends StatefulWidget {
final List players;
const TankBattleGame({super.key, required this.players});
@override
State createState() => _TankBattleGameState();
}
class _TankBattleGameState extends State {
late List<_Tank> _tanks;
final List<_Bullet> _bullets = [];
Timer? _gameTimer;
PlayerInfo? _winner;
final FocusNode _focusNode = FocusNode();
@override
void initState() {
super.initState();
final startsX = [0.2, 0.8, 0.2, 0.8];
final startsY = [0.2, 0.2, 0.8, 0.8];
final startsA = [0.7, 2.4, -0.7, -2.4];
_tanks = List.generate(widget.players.length, (i) {
return _Tank(x: startsX[i], y: startsY[i], angle: startsA[i]);
});
gameTimer = Timer.periodic(const Duration(milliseconds: 30), () => _updateGame());
}
@override
void dispose() {
_gameTimer?.cancel();
super.dispose();
}
void _updateGame() {
if (_winner != null) return;
setState(() {
for (var t in _tanks) {
if (t.alive) t.angle += 0.06;
}
for (int i = _bullets.length - 1; i >= 0; i--) {
final b = _bullets[i];
b.x += b.dx;
b.y += b.dy;
if (b.x < 0 || b.x > 1 || b.y < 0 || b.y > 1) {
_bullets.removeAt(i);
continue;
}
for (int j = 0; j < _tanks.length; j++) {
if (j != b.ownerIndex && _tanks[j].alive) {
final dist = sqrt(pow(b.x - _tanks[j].x, 2) + pow(b.y - _tanks[j].y, 2));
if (dist < 0.08) {
_tanks[j].alive = false;
_bullets.removeAt(i);
_checkWinner();
break;
}
}
}
}
});
}
void _checkWinner() {
final aliveIndices = [];
for (int i = 0; i < _tanks.length; i++) {
if (_tanks[i].alive) aliveIndices.add(i);
}
if (aliveIndices.length == 1) {
_winner = widget.players[aliveIndices.first];
_winner!.score += 1;
_gameTimer?.cancel();
}
}
void _fire(int index) {
if (_winner != null || !_tanks[index].alive) return;
final t = _tanks[index];
t.x = (t.x + cos(t.angle) * 0.03).clamp(0.1, 0.9);
t.y = (t.y + sin(t.angle) * 0.03).clamp(0.1, 0.9);
_bullets.add(_Bullet(
x: t.x,
y: t.y,
dx: cos(t.angle) * 0.025,
dy: sin(t.angle) * 0.025,
ownerIndex: index,
));
}
@override
Widget build(BuildContext context) {
return KeyboardListener(
focusNode: _focusNode,
autofocus: true,
onKeyEvent: (event) {
if (event is KeyDownEvent) {
for (int i = 0; i < widget.players.length; i++) {
if (event.logicalKey == widget.players[i].key) _fire(i);
}
}
},
child: Scaffold(
backgroundColor: Colors.brown.shade900,
appBar: AppBar(title: const Text("نبرد تانک‌ها"), backgroundColor: Colors.deepOrange),
body: Column(
children: [
if (_winner != null)
Container(
width: double.infinity,
padding: const EdgeInsets.all(14),
color: _winner!.color,
child: Column(
children: [
Text("🏆 تانک ${_winner!.name} پیروز شد! 🏆",
style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("بازگشت به منو")),
],
),
),
Expanded(
child: Container(
margin: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: const Color(0xFFD7CCC8),
borderRadius: BorderRadius.circular(16),
border: Border.all(color: Colors.brown, width: 4),
),
child: LayoutBuilder(
builder: (context, constraints) {
return Stack(
children: [
...List.generate(_tanks.length, (i) {
final t = _tanks[i];
if (!t.alive) return const SizedBox.shrink();
return Positioned(
left: t.x * constraints.maxWidth - 20,
top: t.y * constraints.maxHeight - 20,
child: Transform.rotate(
angle: t.angle,
child: Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color: widget.players[i].color,
borderRadius: BorderRadius.circular(8),
border: Border.all(color: Colors.black, width: 2),
),
child: const Align(
alignment: Alignment.centerRight,
child: Icon(Icons.arrow_forward, color: Colors.white, size: 22),
),
),
),
);
}),
..._bullets.map((b) {
return Positioned(
left: b.x * constraints.maxWidth - 6,
top: b.y * constraints.maxHeight - 6,
child: Container(
width: 12,
height: 12,
decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
),
);
}),
],
);
},
),
),
),
_PlayerControlPad(players: widget.players, onPlayerAction: _fire, buttonText: "شلیک 💥"),
],
),
),
);
}
}
class QuickDrawGame extends StatefulWidget {
final List players;
const QuickDrawGame({super.key, required this.players});
@override
State createState() => _QuickDrawGameState();
}
class _QuickDrawGameState extends State {
bool _isGreen = false;
String _status = "صبر کن تا صفحه سبز بشه... 🛑";
PlayerInfo? _winner;
Timer? _timer;
final FocusNode _focusNode = FocusNode();
@override
void initState() {
super.initState();
final delay = Random().nextInt(3500) + 1500;
_timer = Timer(Duration(milliseconds: delay), () {
if (mounted && _winner == null) {
setState(() {
_isGreen = true;
_status = "الان بزن!! ⚡🟢";
});
}
});
}
@override
void dispose() {
_timer?.cancel();
super.dispose();
}
void _press(int index) {
if (_winner != null) return;
if (!_isGreen) {
setState(() {
_status = "خطا! بازیکن ${widget.players[index].name} زودتر زد!";
});
} else {
_timer?.cancel();
setState(() {
_winner = widget.players[index];
_winner!.score += 1;
_status = "⚡ بازیکن ${_winner!.name} سریع‌ترین بود و برنده شد! ⚡";
});
}
}
@override
Widget build(BuildContext context) {
return KeyboardListener(
focusNode: _focusNode,
autofocus: true,
onKeyEvent: (event) {
if (event is KeyDownEvent) {
for (int i = 0; i < widget.players.length; i++) {
if (event.logicalKey == widget.players[i].key) _press(i);
}
}
},
child: Scaffold(
backgroundColor: _isGreen ? Colors.green.shade600 : Colors.red.shade800,
appBar: AppBar(title: const Text("واکنش سریع"), backgroundColor: Colors.black54),
body: Column(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
const SizedBox(height: 20),
Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
children: [
Text(
_status,
textAlign: TextAlign.center,
style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
),
if (_winner != null) ...[
const SizedBox(height: 20),
ElevatedButton(
onPressed: () => Navigator.pop(context),
child: const Text("بازگشت به منوی بازی‌ها"),
)
]
],
),
),
_PlayerControlPad(players: widget.players, onPlayerAction: _press, buttonText: "بزن! ⚡"),
],
),
),
);
}
}
class _PlayerControlPad extends StatelessWidget {
final List players;
final Function(int) onPlayerAction;
final String buttonText;
const _PlayerControlPad({
required this.players,
required this.onPlayerAction,
required this.buttonText,
});
@override
Widget build(BuildContext context) {
return Container(
padding: const EdgeInsets.all(10),
color: Colors.black87,
child: Row(
children: List.generate(players.length, (i) {
final p = players[i];
return Expanded(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 4),
child: GestureDetector(
onTapDown: (_) => onPlayerAction(i),
child: Container(
height: 85,
decoration: BoxDecoration(
color: p.color,
borderRadius: BorderRadius.circular(16),
boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(buttonText, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
Text("${p.name} (${p.keyLabel})", style: const TextStyle(color: Colors.white70, fontSize: 12)),
],
),
),
),
),
);
}),
),
);
}
}
