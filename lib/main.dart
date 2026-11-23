cat << 'EOF' > ~/my_app/lib/main.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: TalkingPetsWorld(),
    ),
  ));
}

class PetCharacter {
  final String name;
  final String normalEmoji;
  final String happyEmoji;
  final String dizzyEmoji;
  final String sleepEmoji;
  final String talkEmoji;
  final Color bodyColor;
  final Color bgColor;
  final double voiceSpeed;

  const PetCharacter({
    required this.name,
    required this.normalEmoji,
    required this.happyEmoji,
    required this.dizzyEmoji,
    required this.sleepEmoji,
    required this.talkEmoji,
    required this.bodyColor,
    required this.bgColor,
    required this.voiceSpeed,
  });
}

class TalkingPetsWorld extends StatefulWidget {
  const TalkingPetsWorld({super.key});

  @override
  State<TalkingPetsWorld> createState() => _TalkingPetsWorldState();
}

class _TalkingPetsWorldState extends State<TalkingPetsWorld>
with SingleTickerProviderStateMixin {
  final List<PetCharacter> _pets = const [
    PetCharacter(
      name: 'گربه تام',
      normalEmoji: '🐱',
      happyEmoji: '😹',
      dizzyEmoji: '😵',
      sleepEmoji: '😴',
      talkEmoji: '🗣️',
      bodyColor: Color(0xFF9E9E9E),
      bgColor: Color(0xFFFFF8E1),
      voiceSpeed: 1.45,
    ),
    PetCharacter(
      name: 'سگ بن',
      normalEmoji: '🐶',
      happyEmoji: '🐕',
      dizzyEmoji: '🤪',
      sleepEmoji: '😴',
      talkEmoji: '🐶',
      bodyColor: Color(0xFF8D6E63),
      bgColor: Color(0xFFEFEBE9),
      voiceSpeed: 0.85,
    ),
    PetCharacter(
      name: 'طوطی پیر',
      normalEmoji: '🦜',
      happyEmoji: '🦚',
      dizzyEmoji: '💫',
      sleepEmoji: '💤',
      talkEmoji: '🦜',
      bodyColor: Color(0xFF43A047),
      bgColor: Color(0xFFE8F5E9),
      voiceSpeed: 1.75,
    ),
    PetCharacter(
      name: 'روباه زرنگ',
      normalEmoji: '🦊',
      happyEmoji: '🦊',
      dizzyEmoji: '😵‍💫',
      sleepEmoji: '😴',
      talkEmoji: '🦊',
      bodyColor: Color(0xFFEF6C00),
      bgColor: Color(0xFFFFF3E0),
      voiceSpeed: 1.30,
    ),
    PetCharacter(
      name: 'ربات هوشمند',
      normalEmoji: '🤖',
      happyEmoji: '👾',
      dizzyEmoji: '💥',
      sleepEmoji: '🔋',
      talkEmoji: '🤖',
      bodyColor: Color(0xFF546E7A),
      bgColor: Color(0xFFECEFF1),
      voiceSpeed: 1.10,
    ),
  ];

  int _selectedPetIndex = 0;
  late String _currentFace;
  String _speechText = 'سلام! من آماده‌ام؛ حرف بزن یا با من بازی کن!';
  String _equippedAccessory = '';
  double _scale = 1.0;

  int _coins = 100;
  int _happiness = 85;
  int _hunger = 75;
  int _energy = 80;

  bool _isSleeping = false;
  bool _isRecording = false;
  bool _isTalking = false;

  late AnimationController _breathingController;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  PetCharacter get _pet => _pets[_selectedPetIndex];

  @override
  void initState() {
    super.initState();
    _currentFace = _pet.normalEmoji;
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.96,
      upperBound: 1.04,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _selectPet(int index) {
    if (_isRecording || _isTalking) return;
    setState(() {
      _selectedPetIndex = index;
      _isSleeping = false;
      _currentFace = _pet.normalEmoji;
      _speechText = 'سلام! من ${_pet.name} هستم! صدام رو امتحان کن!';
    });
  }

  Future<void> _toggleRecording() async {
    if (_isSleeping) {
      setState(() => _speechText = 'هیس! خوابیدم... اول بیدارم کن 💤');
      return;
    }

    if (!_isRecording) {
      if (await _audioRecorder.hasPermission()) {
        String path = '';
        if (!kIsWeb) {
          final dir = await getTemporaryDirectory();
          path = '${dir.path}/pet_voice.m4a';
        }
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _currentFace = '👂';
        _speechText = 'دارم گوش میدم... حرف بزن! 🎙️';
        _scale = 1.15;
        });
      } else {
        setState(() => _speechText = 'اجازه دسترسی به میکروفون داده نشد!');
      }
    } else {
      final recordedPath = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _scale = 1.0;
      });
      if (recordedPath != null) {
        _playPetVoice(recordedPath);
      }
    }
  }

  Future<void> _playPetVoice(String path) async {
    setState(() {
      _isTalking = true;
      _currentFace = _pet.talkEmoji;
      _speechText = '${_pet.name} داره تکرار می‌کنه...';
    });

    try {
      if (kIsWeb) {
        await _audioPlayer.setUrl(path);
      } else {
        await _audioPlayer.setFilePath(path);
      }
      await _audioPlayer.setSpeed(_pet.voiceSpeed);
      await _audioPlayer.play();

      await _audioPlayer.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
    } catch (_) {
      if (mounted) setState(() => _speechText = 'خطا در پخش صدا!');
    } finally {
      if (mounted) {
        setState(() {
          _isTalking = false;
          _currentFace = _pet.normalEmoji;
          _coins += 2;
          _speechText = 'دوباره حرف بزن! (+۲ سکه گرفتی 🪙)';
        });
      }
    }
  }

  void _react(String face, String msg, {int happy = 5, int hunger = 0, int energy = -2}) {
    if (_isSleeping || _isRecording || _isTalking) return;
    setState(() {
      _currentFace = face;
      _speechText = msg;
      _scale = 1.25;
      _happiness = (_happiness + happy).clamp(0, 100);
      _hunger = (_hunger + hunger).clamp(0, 100);
      _energy = (_energy + energy).clamp(0, 100);
    });

    Timer(const Duration(milliseconds: 1600), () {
      if (mounted && !_isSleeping && !_isRecording && !_isTalking) {
        setState(() {
          _currentFace = _pet.normalEmoji;
          _scale = 1.0;
        });
      }
    });
  }

  void _toggleSleep() {
    if (_isRecording || _isTalking) return;
    setState(() {
      _isSleeping = !_isSleeping;
      if (_isSleeping) {
        _currentFace = _pet.sleepEmoji;
        _speechText = 'خوابیدم... انرژی‌ام داره کامل میشه 💤';
    _energy = (_energy + 30).clamp(0, 100);
      } else {
        _currentFace = _pet.normalEmoji;
        _speechText = 'صبح بخیر! پر از انرژی‌ام!';
      }
    });
  }

  void _openFoodMenu() {
    if (_isSleeping) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final foods = [
          {'name': 'شیر تازه', 'icon': '🥛', 'cost': 5, 'hunger': 15, 'face': '😋', 'msg': 'به به! شیر خیلی چسبید!'},
          {'name': 'ماهی کبابی', 'icon': '🐟', 'cost': 10, 'hunger': 25, 'face': '😻', 'msg': 'عالی بود! سیرِ سیر شدم!'},
          {'name': 'پیتزا', 'icon': '🍕', 'cost': 15, 'hunger': 35, 'face': '🤤', 'msg': 'واو! پیتزا حرف نداره!'},
          {'name': 'فلفل تند!', 'icon': '🌶️', 'cost': 5, 'hunger': 5, 'face': '🔥', 'msg': 'آخ سوختم!! دهنم آتیش گرفت 🔥'},
        ];
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('آشپزخانه و یخچال غذاها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...foods.map((food) {
                  final int cost = food['cost'] as int;
                  return ListTile(
                    leading: Text(food['icon'] as String, style: const TextStyle(fontSize: 32)),
                    title: Text(food['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('سیری: +${food['hunger']}%'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        if (_coins >= cost) {
                          Navigator.pop(context);
                          setState(() => _coins -= cost);
                          _react(
                            food['face'] as String,
                            food['msg'] as String,
                            hunger: food['hunger'] as int,
                            happy: 10,
                          );
                        } else {
                          Navigator.pop(context);
                          setState(() => _speechText = 'سکه کافی نداری! برو مینی‌گیم سکه جمع کن 🪙');
                        }
                      },
                      child: Text('$cost 🪙'),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openWardrobe() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final items = [
          {'name': 'بدون کلاه', 'icon': '❌', 'cost': 0},
          {'name': 'تاج پادشاهی', 'icon': '👑', 'cost': 20},
          {'name': 'کلاه جادوگر', 'icon': '🎩', 'cost': 15},
          {'name': 'پاپیون قرمز', 'icon': '🎀', 'cost': 10},
          {'name': 'کلاه ایمنی', 'icon': '⛑️', 'cost': 10},
        ];
        Use code with caution.
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('کمد لباس و کلاه', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: items.map((item) {
                    final int cost = item['cost'] as int;
                    return ActionChip(
                      avatar: Text(item['icon'] as String),
                      label: Text('${item['name']} ($cost 🪙)'),
                      onPressed: () {
                        if (_coins >= cost) {
                          setState(() {
                            _coins -= cost;
                            _equippedAccessory = item['icon'] == '❌' ? '' : item['icon'] as String;
                            _speechText = 'به به! چقدر خوشتیپ شدم!';
                          });
                          Navigator.pop(context);
                        } else {
                          Navigator.pop(context);
                          setState(() => _speechText = 'سکه کافی برای خرید این کلاه نداری!');
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _openMiniGame() {
    showDialog(
      context: context,
      builder: (context) => _CoinMiniGameDialog(
        onCoinsEarned: (earned) {
          setState(() {
            _coins += earned;
            _happiness = (_happiness + 10).clamp(0, 100);
            _speechText = 'آفرین! $earned سکه از بازی بردی! 🎉';
          });
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isSleeping ? Colors.indigo.shade900 : _pet.bgColor,
      appBar: AppBar(
        backgroundColor: _isSleeping ? Colors.indigo : _pet.bodyColor,
        title: Text(_pet.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$_coins 🪙',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 65,
            color: Colors.black.withOpacity(0.05),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _pets.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedPetIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    selected: isSelected,
                    selectedColor: _pets[index].bodyColor,
                    label: Text(
                      '${_pets[index].normalEmoji} ${_pets[index].name}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSelected: (bool selected) => _selectPet(index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statusPill('شادی', _happiness, Colors.pink),
                _statusPill('سیری', _hunger, Colors.orange),
                _statusPill('انرژی', _energy, Colors.green),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Text(
              _speechText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ScaleTransition(
            scale: _breathingController,
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 200),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () => _react(_pet.dizzyEmoji, 'آخ! سرم گیج رفت!', happy: -5),
                        child: Text(_currentFace, style: const TextStyle(fontSize: 105)),
                      ),
                      if (_equippedAccessory.isNotEmpty)
                        Positioned(
                          top: -28,
                          child: Text(_equippedAccessory, style: const TextStyle(fontSize: 48)),
                        ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _react(_pet.happyEmoji, 'هاهاها! قلقلکم میاد!', happy: 10),
                    child: Container(
                      width: 135,
                      height: 140,
                      decoration: BoxDecoration(
                        color: _pet.bodyColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(50),
                          bottom: Radius.circular(70),
                        ),
                        border: Border.all(color: Colors.black26, width: 3),
                      ),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Center(
                            child: Text('قلقلکم بده', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          FloatingActionButton.extended(
            onPressed: _toggleRecording,
            backgroundColor: _isRecording ? Colors.red : Colors.teal,
            icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 26),
            label: Text(
              _isRecording ? 'توقف و تکرار صدا' : 'حرف بزن تا تکرار کنم',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
            decoration: BoxDecoration(
              color: _isSleeping ? Colors.indigo.shade800 : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomIconBtn(Icons.restaurant, 'غذا', Colors.redAccent, _openFoodMenu),
                _bottomIconBtn(Icons.favorite, 'نوازش', Colors.pink, () {
                  _react(_pet.happyEmoji, 'ممنون! خیلی مهربونی ❤️', happy: 12);
                }),
                _bottomIconBtn(Icons.checkroom, 'لباس', Colors.orange, _openWardrobe),
                _bottomIconBtn(Icons.sports_esports, 'بازی', Colors.blue, _openMiniGame),
                _bottomIconBtn(
                  _isSleeping ? Icons.wb_sunny : Icons.bedtime,
                  _isSleeping ? 'بیدار' : 'خواب',
                  Colors.deepPurple,
                  _toggleSleep,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _statusPill(String label, int val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: Text(
        '$label: $val%',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
  Widget _bottomIconBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
class _CoinMiniGameDialog extends StatefulWidget {
  final Function(int) onCoinsEarned;
  const _CoinMiniGameDialog({required this.onCoinsEarned});
  @override
  State<_CoinMiniGameDialog> createState() => _CoinMiniGameDialogState();
}
class _CoinMiniGameDialogState extends State<_CoinMiniGameDialog> {
  int _score = 0;
  double _top = 80;
  double _left = 80;
  final Random _random = Random();
  void _tapCoin() {
    setState(() {
      _score += 5;
      _top = _random.nextDouble() * 160 + 10;
      _left = _random.nextDouble() * 180 + 10;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text('مینی‌گیم سکه! امتیاز: $_score 🪙'),
        content: SizedBox(
          width: 260,
          height: 230,
          child: Stack(
            children: [
              const Center(
                child: Text('سریع روی سکه‌ها بزن!', style: TextStyle(color: Colors.grey)),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                top: _top,
                left: _left,
                child: GestureDetector(
                  onTap: _tapCoin,
                  child: const Text('🪙', style: TextStyle(fontSize: 48)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              widget.onCoinsEarned(_score);
              Navigator.pop(context);
            },
            child: const Text('دریافت سکه‌ها و خروج'),
          ),
        ],
      ),
    );
  }
}
