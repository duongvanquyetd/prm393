import 'package:confetti/confetti.dart';
import 'package:dua_thuyen/services/audio_service.dart';
import 'package:flutter/material.dart';

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

  const RaceScreen({
    super.key,
    required this.horses,
    required this.bets,
    required this.totalMoney,
  });

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  final RaceController raceController = RaceController();
  final GameAudioService audioService = GameAudioService.instance;
  late ConfettiController confettiController;

  bool isRunning = false;

  @override
  void initState() {
    super.initState();

    // Vào màn đua thì xoay ngang
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Ẩn thanh hệ thống để màn đua rộng hơn
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    audioService.playBackgroundMusic();
    audioService.playBackgroundMusic();
  }

  @override
  void dispose() {
    raceController.dispose();
    confettiController.dispose();

    super.dispose();
  }

  void startRace(double finishLine) {
    setState(() {
      isRunning = true;
    });

    // Tiếng ngựa hí + tiếng chân ngựa phát chồng lên nhạc nền
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
        });

        // Chỉ dừng tiếng chân ngựa, KHÔNG dừng nhạc nền
        await audioService.stopHorseRunSound();

        // Pháo hoa phát chồng lên nhạc nền
        await audioService.playFireworkSound();

        confettiController.play();

        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
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
      backgroundColor: const Color(0xff06283d),
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),
            Expanded(child: buildRaceArea()),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(14),
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

  Widget buildRaceArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double raceWidth = constraints.maxWidth;
        final double raceHeight = constraints.maxHeight;

        final double horseWidth = 110;

        // Vị trí bắt đầu của ngựa ở sát bên phải
        final double startX = raceWidth - horseWidth - 10;

        // Vạch đích bên trái
        final double finishX = 40;

        // Quãng đường ngựa cần chạy
        final double finishLine = startX - finishX;
        final double lane1 = raceHeight * 0.45;
        final double lane2 = raceHeight * 0.56;
        final double lane3 = raceHeight * 0.70;

        return Container(
          margin: const EdgeInsets.all(12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xffc8873f),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
          ),
          child: Stack(
            children: [
              buildBackground(),

              // Positioned(
              //   right: 55,
              //   top: 20,
              //   bottom: 20,
              //   child: Container(
              //     width: 6,
              //     color: Colors.white,
              //   ),
              // ),
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

              Positioned(
                bottom: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: isRunning ? null : () => startRace(finishLine),
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
                      isRunning ? 'ĐANG ĐUA...' : 'BẮT ĐẦU',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
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
          ),
        );
      },
    );
  }

  Widget buildBackground() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
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
      ),
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
