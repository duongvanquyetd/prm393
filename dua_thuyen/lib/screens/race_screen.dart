import 'package:confetti/confetti.dart';
import 'package:dua_thuyen/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../controllers/race_controller.dart';
import '../models/bet.dart';
import '../models/horse.dart';
import '../widgets/horse_track.dart';
import 'result_screen.dart';
import 'package:flutter/services.dart';

class RaceScreen extends StatefulWidget {
  final List<Horse> horses;
  final List<Bet> bets;
  final int totalMoney;
  final int userId;

  const RaceScreen({
    super.key,
    required this.horses,
    required this.bets,
    required this.totalMoney,
    required this.userId,
  });

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  final RaceController raceController = RaceController();
  final GameAudioService audioService = GameAudioService.instance;
  late ConfettiController confettiController;

  bool isRunning = false;
  bool isCountingDown = false;
  bool isFinished = false;
  int countdownNumber = 3;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    unawaited(audioService.pauseForRace());
    unawaited(audioService.stopAllEffects());
  }

  @override
  void dispose() {
    raceController.dispose();
    confettiController.dispose();

    audioService.stopHorseRunSound();
    unawaited(audioService.resumeAfterRace());

    super.dispose();
  }

  Future<void> startRace(double finishLine) async {

    if (isRunning || isCountingDown || isFinished) return;

    setState(() {
      isCountingDown = true;
      isFinished = false;
      countdownNumber = 3;
    });

    // Bật nhạc đếm ngược
    audioService.playCountdownSound();

    // Vòng lặp đếm 3, 2, 1
    for (int i = 3; i > 0; i--) {
      if (!mounted) return;
      setState(() {
        countdownNumber = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;

    // Kết thúc đếm ngược, bắt đầu cho ngựa chạy
    setState(() {
      isCountingDown = false;
      isRunning = true;
    });

    audioService.playHorseNeighSound();
    audioService.playHorseRunSound();

    raceController.startRace(
      horses: widget.horses,
      finishLine: finishLine,
      onUpdate: () {
        setState(() {});
      },
      onFinish: (winner) async {
        setState(() {
          isRunning = false;
          isFinished = true;
        });

        unawaited(audioService.playHorseNeighSound());
        unawaited(audioService.stopHorseRunSound());

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                userId: widget.userId,
                horses: widget.horses,
                bets: widget.bets,
                winner: winner,
                oldMoney: widget.totalMoney,
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          buildRaceArea(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: buildHeader(),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(4, topPadding, 12, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.55),
            Colors.black.withOpacity(0.25),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: isRunning ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'CƯỢC ĐUA NGỰA',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.monetization_on, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            widget.totalMoney.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget  buildRaceArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double raceWidth = constraints.maxWidth;
        final double raceHeight = constraints.maxHeight;

        final double horseWidth = 110;

        final double startX = raceWidth - horseWidth - 10;

        final double finishX = 40;

        final double finishLine = startX - finishX;
        final double lane1 = raceHeight * 0.50;
        final double lane2 = raceHeight * 0.63;
        final double lane3 = raceHeight * 0.76;
        final double headerInset = MediaQuery.of(context).padding.top + 52;

        return Stack(
          fit: StackFit.expand,
          children: [
            buildBackground(),
            Positioned(
              top: headerInset,
              right: 14,
              child: buildHorseProgressPanel(),
            ),
              HorseTrack(
                horse: widget.horses[0],
                top: lane1,
                isRunning: isRunning,
                startX: startX,
              ),

              HorseTrack(
                horse: widget.horses[1],
                top: lane2,
                isRunning: isRunning,
                startX: startX,
              ),

              HorseTrack(
                horse: widget.horses[2],
                top: lane3,
                isRunning: isRunning,
                startX: startX,
              ),

              if (!isRunning && !isFinished)
                Positioned(
                  bottom: 18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: isCountingDown
                          ? null
                          : () => startRace(finishLine),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 55,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        isCountingDown ? 'CHUẨN BỊ...' : 'BẮT ĐẦU',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

              if (isCountingDown)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45, // Nền làm mờ một chút
                    child: Center(
                      child: Text(
                        countdownNumber.toString(),
                        style: const TextStyle(
                          fontSize: 120,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.white,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              Align(
                alignment: Alignment.topLeft,
                child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  numberOfParticles: 30,
                  gravity: 0.25,
                ),
              ),

              Align(
                alignment: Alignment.topRight,
                child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  numberOfParticles: 30,
                  gravity: 0.25,
                ),
              ),
            ],
        );
      },
    );
  }
  Widget buildHorseProgressPanel() {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          for (final horse in widget.horses)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: horse.color,
                      child: Image.asset(
                        horse.frames.first,
                        fit: BoxFit.contain,
                      ),
                  ),

                  const SizedBox(width: 6),

                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: horse.progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: horse.color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),

                  const SizedBox(width: 5),

                  Text(
                    '${(horse.progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  Widget buildBackground() {
    return Image.asset(
      'assets/images/duong_dua.png',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xffc8873f),
          alignment: Alignment.center,
          child: const Text(
            'Không tìm thấy ảnh duong_dua.png',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget buildInfoPanel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff09263d),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'HIỆU ỨNG GAME',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 14),
            Text(
              '✓ Ngựa tự random tốc độ liên tục\n'
              '✓ Không cần chỉnh tốc độ thủ công\n'
              '✓ Mỗi con chạy lúc nhanh lúc chậm\n'
              '✓ Con nào chạm đích trước sẽ thắng',
              style: TextStyle(color: Colors.white, fontSize: 17, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}


class AnimatedHorse extends StatefulWidget {
  final List<String> frames;
  final bool isRunning;
  final double width;

  const AnimatedHorse({
    super.key,
    required this.frames,
    required this.isRunning,
    this.width = 110,
  });

  @override
  State<AnimatedHorse> createState() => _AnimatedHorseState();
}

class _AnimatedHorseState extends State<AnimatedHorse> {
  int frameIndex = 0;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(milliseconds: 120),
          (_) {
        if (!widget.isRunning) return;

        setState(() {
          frameIndex =
              (frameIndex + 1) % widget.frames.length;
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      widget.frames[frameIndex],
      width: widget.width,
      fit: BoxFit.contain,
    );
  }
}
