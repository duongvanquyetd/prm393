import 'dart:async';
import 'dart:math';

import '../models/horse.dart';

class RaceController {
  final Random _random = Random();

  Timer? _timer;
  bool isRunning = false;

  final Map<int, double> _midGameBoosts = {};
  final Map<int, double> _lateGameBoosts = {};

  void startRace({
    required List<Horse> horses,
    required double finishLine,
    required Function() onUpdate,
    required Function(Horse winner) onFinish,
  }) {
    if (isRunning) return;

    isRunning = true;

    _midGameBoosts.clear();
    _lateGameBoosts.clear();

    for (final horse in horses) {
      horse.reset();
      horse.progress = 0;
    }

    List<Horse> shuffled = List.from(horses)..shuffle(_random);

    int midGameCount = _random.nextInt(2) + 1;
    for (int i = 0; i < midGameCount; i++) {
      _midGameBoosts[shuffled[i].hashCode] = 1.0 + _random.nextDouble() * 1.0;
    }

    shuffled.shuffle(_random);
    int lateGameCount = _random.nextInt(2) + 1;
    for (int i = 0; i < lateGameCount; i++) {
      _lateGameBoosts[shuffled[i].hashCode] = 4.5 + _random.nextDouble() * 2.0;
    }

    _timer = Timer.periodic(const Duration(milliseconds: 45), (timer) {

      double maxPosition = horses.fold(0.0, (maxPos, h) => max(maxPos, h.position));
      double globalProgress = maxPosition / finishLine;

      for (final horse in horses) {
        if (!horse.finished) {
          double speed = 0;

          if (globalProgress < 0.25) {
            speed = 1.5 + _random.nextDouble() * 1.0;
          } else if (globalProgress < 0.85) {
            double baseSpeed = 1.2 + _random.nextDouble() * 1.5;
            double boost = _midGameBoosts[horse.hashCode] ?? 0.0;
            speed = baseSpeed + boost;

          } else {
            double baseSpeed = 1.0 + _random.nextDouble() * 1.5;
            double boost = _lateGameBoosts[horse.hashCode] ?? 0.0;
            speed = baseSpeed + boost;
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