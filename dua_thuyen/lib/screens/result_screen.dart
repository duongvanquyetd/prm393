import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/bet.dart';
import '../models/horse.dart';
import 'home_screen.dart';
import '../services/audio_service.dart';
class ResultScreen extends StatefulWidget {
  final List<Horse> horses;
  final List<Bet> bets;
  final Horse winner;
  final int oldMoney;

  const ResultScreen({
    super.key,
    required this.horses,
    required this.bets,
    required this.winner,
    required this.oldMoney,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    GameAudioService.instance.playBackgroundMusic();
  }

  int calculateNewMoney() {
    int money = widget.oldMoney;

    for (final bet in widget.bets) {
      if (bet.amount <= 0) continue;

      if (bet.horseId == widget.winner.id) {
        money += bet.amount;
      } else {
        money -= bet.amount;
      }
    }

    return money;
  }

  Horse findHorseById(int id) {
    return widget.horses.firstWhere((horse) => horse.id == id);
  }

  void continueRace() {
    GameAudioService.instance.resumeBackgroundMusic();
    final newMoney = calculateNewMoney();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          initialMoney: newMoney,
          landscapeMode: true,
        ),
      ),
          (route) => false,
    );
  }

  void backToHome() {
    GameAudioService.instance.resumeBackgroundMusic();
    final newMoney = calculateNewMoney();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          initialMoney: newMoney,
          landscapeMode: false,
        ),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final newMoney = calculateNewMoney();

    return Scaffold(
      backgroundColor: const Color(0xff06283d),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: buildWinnerBox(newMoney),
              ),

              const SizedBox(width: 18),

              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    const Text(
                      'BẢNG CƯỢC',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: ListView(
                        children: [
                          for (final bet in widget.bets)
                            buildBetResultRow(bet),
                        ],
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: continueRace,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'TIẾP TỤC ĐUA',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: backToHome,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'VỀ HOME',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWinnerBox(int newMoney) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff0b3954),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'KẾT QUẢ CUỘC ĐUA',
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'NGỰA CHIẾN THẮNG',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: 120,
            height: 90,
            child: Image.asset(
              widget.winner.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Text(
                  '🐎',
                  style: TextStyle(
                    fontSize: 70,
                    color: widget.winner.color,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Text(
            widget.winner.name,
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Tiền ban đầu: ${widget.oldMoney}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Tiền hiện tại: $newMoney',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBetResultRow(Bet bet) {
    final horse = findHorseById(bet.horseId);
    final isWin = horse.id == widget.winner.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff0b3954),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWin ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 44,
            child: Image.asset(
              horse.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Text(
                  '🐎',
                  style: TextStyle(
                    fontSize: 32,
                    color: horse.color,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              horse.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Text(
            '${bet.amount}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),

          const SizedBox(width: 16),

          Text(
            isWin ? 'WIN' : 'LOSE',
            style: TextStyle(
              color: isWin ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}