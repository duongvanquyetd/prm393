import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/audio_service.dart';
import '../models/bet.dart';
import '../models/horse.dart';
import '../widgets/bet_input_row.dart';
import 'race_screen.dart';
import 'auth_screen.dart';
class HomeScreen extends StatefulWidget {
  final int userId;
  final int initialMoney;
  final bool landscapeMode;

  const HomeScreen({
    super.key,
    required this.userId,
    this.initialMoney = 12500,
    this.landscapeMode = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int totalMoney;

  late List<Horse> horses;
  late List<TextEditingController> betControllers;

  @override
  void initState() {
    super.initState();

    totalMoney = widget.initialMoney;

    if (widget.landscapeMode) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    Future.microtask(() async {
      await GameAudioService.instance.restartBackgroundMusic();
    });
    horses = [
      Horse(
        id: 1,
        name: 'THẦN PHONG',
        imagePath: 'assets/images/ngua_do_1.png',
        color: Colors.red,
        frames: [
          'assets/images/ngua_do_1.png',
          'assets/images/ngua_do_2.png',
          'assets/images/ngua_do_3.png',
        ],
      ),
      Horse(
        id: 2,
        name: 'BẠCH MÃ',
        imagePath: 'assets/images/ngua_xanh_la_cay_1.png',
        color: Colors.green,
        frames: [
          'assets/images/ngua_xanh_la_cay_1.png',
          'assets/images/ngua_xanh_la_cay_2.png',
          'assets/images/ngua_xanh_la_cay_3.png',
        ],
      ),
      Horse(
        id: 3,
        name: 'LONG VŨ',
        imagePath: 'assets/images/ngua_xanh_troi_1.png',
        color: Colors.blue,
        frames: [
          'assets/images/ngua_xanh_troi_1.png',
          'assets/images/ngua_xanh_troi_2.png',
          'assets/images/ngua_xanh_troi_3.png',
        ],
      ),
    ];

    betControllers = List.generate(
      horses.length,
          (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (final controller in betControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  int getTotalBet() {
    int sum = 0;

    for (final controller in betControllers) {
      final value = int.tryParse(controller.text) ?? 0;
      sum += value;
    }

    return sum;
  }

  List<Bet> getBets() {
    final List<Bet> bets = [];

    for (int i = 0; i < horses.length; i++) {
      final amount = int.tryParse(betControllers[i].text) ?? 0;

      bets.add(
        Bet(
          horseId: horses[i].id,
          amount: amount,
        ),
      );
    }

    return bets;
  }

  void startGame() {
    final totalBet = getTotalBet();

    if (totalBet <= 0) {
      showMessage('Bạn phải đặt cược trước khi đua');
      return;
    }

    if (totalBet > totalMoney) {
      showMessage('Tổng tiền cược không đủ để đặt cược');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RaceScreen(
          horses: horses,
          bets: getBets(),
          totalMoney: totalMoney,
          userId: widget.userId,
        ),
      ),
    );;
  }

  void showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 8),
              Text('Thông báo'),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  void showHowToPlayDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return SafeArea(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Row(
              children: [
                Icon(Icons.help_outline, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Hướng dẫn chơi',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            content: const SingleChildScrollView(
              child: Text(
                '1. Người chơi chọn 1 trong 3 con ngựa để đặt cược.\n\n'
                    '2. Có thể đặt cược vào 1 con ngựa hoặc nhiều con nếu muốn.\n\n'
                    '3. Nhập số tiền cược vào ô của con ngựa bạn chọn.\n\n'
                    '4. Tổng tiền cược không được vượt quá số tiền hiện có.\n\n'
                    '5. Sau khi nhập tiền, bấm “BẮT ĐẦU ĐUA”.\n\n'
                    '6. Nếu ngựa bạn đặt cược chiến thắng, bạn sẽ nhận thưởng.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'ĐÃ HIỂU',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    if (widget.landscapeMode) {
      return buildLandscapeHome();
    }

    return buildPortraitHome();
  }
  Widget buildPortraitHome() {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    const Color(0xff03263a).withOpacity(0.88),
                    const Color(0xff021d2e),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeader(),
                  const SizedBox(height: 26),

                Center(
                  child: Text(
                    'ĐẶT CƯỢC',
                    style: TextStyle(
                      color: Color(0xffffe44d),
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                  const SizedBox(height: 18),

                  for (int i = 0; i < horses.length; i++)
                    BetInputRow(
                      horse: horses[i],
                      controller: betControllers[i],
                    ),

                  const Spacer(),

                  Column(
                    children: [
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom + 8,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffffa000),
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'BẮT ĐẦU ĐUA',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
    onPressed: () async {
    await GameAudioService.instance.stopBackgroundMusic();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
    builder: (_) => const AuthScreen(),
    ),
    (route) => false,
    );
    },
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'VỀ ĐĂNG NHẬP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.white54,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }Widget buildLandscapeHome() {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildHeader(),
                        const Spacer(),
                        const Text(
                          'ĐẶT CƯỢC',
                          style: TextStyle(
                            color: Color(0xffffe44d),
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Chọn số tiền cược cho từng con ngựa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              for (int i = 0; i < horses.length; i++)
                                BetInputRow(
                                  horse: horses[i],
                                  controller: betControllers[i],
                                ),
                            ],
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: startGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffffa000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'BẮT ĐẦU ĐUA',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Thiên mã bất bại',
            style: TextStyle(
              color: const Color(0xffffa000),
              fontSize: 26,
              fontWeight: FontWeight.w900,

            ),
          ),
        ),

        IconButton(
          onPressed: showHowToPlayDialog,
          icon: const Icon(
            Icons.help_outline,
            color: Colors.white,
            size: 30,
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 22),
              const SizedBox(width: 6),
              Text(
                totalMoney.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}