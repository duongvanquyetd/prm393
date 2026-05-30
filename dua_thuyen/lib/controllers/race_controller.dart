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
    }

    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      for (final horse in horses) {
        if (!horse.finished) {
          /*
            Random tốc độ liên tục:
            Mỗi 40ms, mỗi con ngựa sẽ có tốc độ mới.
            Nhờ vậy ngựa chạy lúc nhanh lúc chậm.
          */
          final double randomSpeed = 2 + _random.nextDouble() * 6;

          horse.position += randomSpeed;

          if (horse.position >= finishLine) {
            horse.position = finishLine;
            horse.finished = true;

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