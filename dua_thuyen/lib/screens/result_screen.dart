import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/bet.dart';
import '../models/horse.dart';
import '../services/audio_service.dart';
import '../services/local_db_service.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final List<Horse> horses;
  final List<Bet> bets;
  final Horse winner;
  final int oldMoney;
  final int userId;

  const ResultScreen({
    super.key,
    required this.horses,
    required this.bets,
    required this.winner,
    required this.oldMoney,
    required this.userId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final int newMoney;
  late final bool wonMoney;
  bool saved = false;
  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();

    newMoney = calculateNewMoney();
    wonMoney = newMoney > widget.oldMoney;

    confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    Future.microtask(() async {
      await GameAudioService.instance.resumeAfterRace();

      if (wonMoney) {
        await GameAudioService.instance.playFireworkSound();
        confettiController.play();
      } else {
        await GameAudioService.instance.playWrongAnswerSound();
      }

      await saveMoney();
    });
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
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

    if (money < 0) return 0;
    return money;
  }

  Future<void> saveMoney() async {
    if (saved) return;

    await LocalDbService.instance.updateUserPrice(
      widget.userId,
      newMoney.toDouble(),
    );

    saved = true;
  }

  Horse findHorseById(int id) {
    return widget.horses.firstWhere((horse) => horse.id == id);
  }

  Future<void> continueRace() async {
    await saveMoney();

    if (newMoney <= 0) {
      showOutOfMoneyDialog();
      return;
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          userId: widget.userId,
          initialMoney: newMoney,
          landscapeMode: true,
        ),
      ),
          (route) => false,
    );
  }

  Future<void> backToHome() async {
    await saveMoney();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          userId: widget.userId,
          initialMoney: newMoney,
          landscapeMode: false,
        ),
      ),
          (route) => false,
    );
  }

  void showOutOfMoneyDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Hết tiền'),
            ],
          ),
          content: const Text(
            'Bạn đã hết tiền nên không thể tiếp tục đua nữa.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                backToHome();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                'Về trang chủ',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool outOfMoney = newMoney <= 0;

    return Scaffold(
      backgroundColor: const Color(0xff06283d),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: buildWinnerBox(outOfMoney),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        const FittedBox(
                          child: Text(
                            'BẢNG CƯỢC',
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: [
                          for (final bet in widget.bets) buildBetResultRow(bet),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: outOfMoney ? null : continueRace,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              outOfMoney ? Colors.grey : Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: FittedBox(
                              child: Text(
                                outOfMoney ? 'HẾT TIỀN' : 'TIẾP TỤC ĐUA',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const FittedBox(
                              child: Text(
                                'VỀ TRANG CHỦ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
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
          if (wonMoney) ...[
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
        ],
      ),
    );
  }

  Widget buildWinnerBox(bool outOfMoney) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xff0b3954),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FittedBox(
            child: Text(
              'KẾT QUẢ CUỘC ĐUA',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'NGỰA CHIẾN THẮNG',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          // Dùng Expanded cho hình ảnh để tự co giãn linh hoạt theo chiều dọc
          Expanded(
            child: Image.asset(
              widget.winner.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return FittedBox(
                  child: Text(
                    '🐎',
                    style: TextStyle(
                      fontSize: 60,
                      color: widget.winner.color,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              widget.winner.name,
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Sử dụng Row thay vì Column cho phần tiền bạc để tiết kiệm chiều dọc
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tiền ban đầu:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${widget.oldMoney}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tiền hiện tại:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '$newMoney',
                style: TextStyle(
                  color: outOfMoney ? Colors.redAccent : Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (outOfMoney) ...[
            const SizedBox(height: 6),
            const Text(
              'Bạn đã hết tiền!',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildBetResultRow(Bet bet) {
    final horse = findHorseById(bet.horseId);
    final isWin = horse.id == widget.winner.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xff0b3954),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWin ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 36, // Giảm chiều cao ảnh để hàng cược thon gọn hơn
            child: Image.asset(
              horse.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return FittedBox(
                  child: Text(
                    '🐎',
                    style: TextStyle(
                      color: horse.color,
                    ),
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
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${bet.amount}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 45,
            child: Text(
              isWin ? 'WIN' : 'LOSE',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isWin ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}