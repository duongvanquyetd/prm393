import 'dart:async';
import 'dart:math';

import '../models/horse.dart';

class RaceController {
  final Random _random = Random();

  Timer? _timer;
  bool isRunning = false;

  void startRace({
    required List<Horse> horses,
    required double finishLine,
    required Function() onUpdate,
    required Function(Horse winner) onFinish,
  }) {
    if (isRunning) return;

    isRunning = true;

    for (final horse in horses) {
      horse.reset();
      horse.progress = 0;
    }

    _timer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      for (final horse in horses) {
        if (!horse.finished) {
          final double progress = horse.position / finishLine;

          double speed;

          // 85% đầu: chạy chậm hơn
          if (progress < 0.85) {
            speed = 1.2 + _random.nextDouble() * 2.5;
          }
          // 15% cuối: tăng tốc
          else {
            speed = 4.2 + _random.nextDouble() * 3.8;
          }

          horse.position += speed;

          if (horse.position >= finishLine) {
            horse.position = finishLine;
            horse.finished = true;
          }

          horse.progress = (horse.position / finishLine).clamp(0.0, 1.0);

          if (horse.finished) {
            stopRace();
            onFinish(horse);
            return;
          }
        }
      }

      onUpdate();
    });
  }

  void stopRace() {
    _timer?.cancel();
    isRunning = false;
  }

  void dispose() {
    _timer?.cancel();
  }
}