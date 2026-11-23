import 'dart:async';
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
      child: TalkingPetGame(),
    ),
  ));
}

class TalkingPetGame extends StatefulWidget {
  const TalkingPetGame({super.key});

  @override
  State<TalkingPetGame> createState() => _TalkingPetGameState();
}

class _TalkingPetGameState extends State<TalkingPetGame>
with SingleTickerProviderStateMixin {
  String _mood = 'سلام! دکمه میکروفون را بزن و حرف بزن تا تکرار کنم!';
  String _faceEmoji = '🐱';
  double _scale = 1.0;
  int _happiness = 80;
  int _energy = 70;
  bool _isSleeping = false;
  bool _isRecording = false;
  bool _isTalking = false;

  late AnimationController _breathingController;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
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

  // شروع و پایان ضبط صدا و پخش با صدای کارتونی
  Future<void> _toggleRecording() async {
    if (_isSleeping) {
      setState(() => _mood = 'الان خوابیدم! اول بیدارم کن 💤');
      return;
    }

    if (!_isRecording) {
      // بررسی مجوز میکروفون
      if (await _audioRecorder.hasPermission()) {
        String path = '';
        if (!kIsWeb) {
          final dir = await getTemporaryDirectory();
          path = '${dir.path}/pet_voice.m4a';
        }

        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _faceEmoji = '👂';
        _mood = 'دارم گوش میدم... حرف بزن! 🎙️';
        _scale = 1.15;
        });
      } else {
        setState(() => _mood = 'لطفاً اجازه دسترسی به میکروفون را بده!');
      }
    } else {
      // پایان ضبط و دریافت مسیر یا آدرس صوتی
      final recordedPath = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _scale = 1.0;
      });

      if (recordedPath != null) {
        _playFunnyVoice(recordedPath);
      }
    }
  }

  // پخش صدا با سرعت و زیر و بمی بالا (مشابه تاکینگ تام)
  Future<void> _playFunnyVoice(String path) async {
    setState(() {
      _isTalking = true;
      _faceEmoji = '🗣️';
    _mood = 'تکرار می‌کنم... 😹';
    });

    try {
      if (kIsWeb) {
        await _audioPlayer.setUrl(path);
      } else {
        await _audioPlayer.setFilePath(path);
      }

      // تغییر سرعت و زیر و بمی صدا (1.45 صدای بامزه و کارتونی ایجاد می‌کند)
      await _audioPlayer.setSpeed(1.45);
      await _audioPlayer.play();

      // صبر تا پایان پخش صدا
      await _audioPlayer.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _mood = 'خطا در پخش صدا!');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTalking = false;
          _faceEmoji = '🐱';
        _mood = 'دوباره حرف بزن! خیلی بامزه بود 😄';
        });
      }
    }
  }

  void _react(String newEmoji, String message, {int happyChange = 5, int energyChange = -2}) {
    if (_isSleeping || _isRecording || _isTalking) return;

    setState(() {
      _faceEmoji = newEmoji;
      _mood = message;
      _scale = 1.25;
      _happiness = (_happiness + happyChange).clamp(0, 100);
      _energy = (_energy + energyChange).clamp(0, 100);
    });

    Timer(const Duration(milliseconds: 1500), () {
      if (mounted && !_isSleeping && !_isRecording && !_isTalking) {
        setState(() {
          _faceEmoji = '🐱';
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
        _faceEmoji = '😴';
    _mood = 'خوابیدم... انرژی‌ام داره پر میشه 💤';
    _energy = (_energy + 25).clamp(0, 100);
      } else {
        _faceEmoji = '😸';
    _mood = 'صبح بخیر! آماده‌ام برای صحبت کردن!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isSleeping ? Colors.indigo.shade900 : Colors.amber.shade50,
      appBar: AppBar(
        title: const Text('گربه سخنگوی من'),
        backgroundColor: _isSleeping ? Colors.indigo : Colors.orange,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusBadge('شادی', _happiness, Colors.pink),
                _buildStatusBadge('انرژی', _energy, Colors.green),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Text(
              _mood,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          ScaleTransition(
            scale: _breathingController,
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 200),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _react('😵', 'آخ! سرم گیج رفت!', happyChange: -5),
                    child: Text(
                      _faceEmoji,
                      style: const TextStyle(fontSize: 110),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _react('😹', 'هاهاها! قلقلکم میاد!', happyChange: 10),
                    child: Container(
                      width: 140,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(50),
                          bottom: Radius.circular(70),
                        ),
                        border: Border.all(color: Colors.grey.shade600, width: 3),
                      ),
                      child: Center(
                        child: Container(
                          width: 85,
                          height: 95,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(45),
                          ),
                          child: const Center(
                            child: Text('شکمم رو بزن', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // دکمه بزرگ ضبط و تکرار صدا
          FloatingActionButton.extended(
            onPressed: _toggleRecording,
            backgroundColor: _isRecording ? Colors.red : Colors.teal,
            icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 28),
            label: Text(
              _isRecording ? 'توقف و پخش صدا' : 'ضبط صدا و تکرار',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: _isSleeping ? Colors.indigo.shade800 : Colors.orange.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.restaurant,
                  label: 'غذا دادن',
                  color: Colors.redAccent,
                  onTap: () => _react('😋', 'به به! شیر و ماهی خیلی خوشمزه بود!', happyChange: 8, energyChange: 15),
                ),
                _buildActionButton(
                  icon: Icons.favorite,
                  label: 'نوازش',
                  color: Colors.pink,
                  onTap: () => _react('😻', 'ممنون! خیلی دوستت دارم ❤️', happyChange: 15, energyChange: -1),
                ),
                _buildActionButton(
                  icon: _isSleeping ? Icons.wb_sunny : Icons.bedtime,
                  label: _isSleeping ? 'بیدار شو' : 'خوابیدن',
                  color: Colors.deepPurple,
                  onTap: _toggleSleep,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
