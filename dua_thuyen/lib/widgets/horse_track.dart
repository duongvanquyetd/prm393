import 'dart:async';
import 'package:flutter/material.dart';

import '../models/horse.dart';

class HorseTrack extends StatelessWidget {
  final Horse horse;
  final double top;
  final bool isRunning;
  final double startX;

  const HorseTrack({
    super.key,
    required this.horse,
    required this.top,
    required this.isRunning,
    required this.startX,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: startX - horse.position,
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 80,
            child: AnimatedHorse(
              horse: horse,
              isRunning: isRunning && !horse.finished,
            ),
          ),

          if (isRunning && !horse.finished)
            const Text(
              '💨',
              style: TextStyle(fontSize: 26),
            ),
        ],
      ),
    );
  }
}

class AnimatedHorse extends StatefulWidget {
  final Horse horse;
  final bool isRunning;

  const AnimatedHorse({
    super.key,
    required this.horse,
    required this.isRunning,
  });

  @override
  State<AnimatedHorse> createState() => _AnimatedHorseState();
}

class _AnimatedHorseState extends State<AnimatedHorse> {
  int frameIndex = 0;
  Timer? timer;

  List<String> get frames {
    if (widget.horse.id == 1) {
      return [
        'assets/images/ngua_do_1.png',
        'assets/images/ngua_do_2.png',
        'assets/images/ngua_do_3.png',
      ];
    }

    if (widget.horse.id == 2) {
      return [
        'assets/images/ngua_xanh_la_cay_1.png',
        'assets/images/ngua_xanh_la_cay_2.png',
        'assets/images/ngua_xanh_la_cay_3.png',
      ];
    }

    return [
      'assets/images/ngua_xanh_troi_1.png',
      'assets/images/ngua_xanh_troi_2.png',
      'assets/images/ngua_xanh_troi_3.png',
    ];
  }

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(milliseconds: 100),
          (_) {
        if (!mounted) return;

        if (widget.isRunning) {
          setState(() {
            frameIndex = (frameIndex + 1) % frames.length;
          });
        } else {
          setState(() {
            frameIndex = 0;
          });
        }
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
      frames[frameIndex],
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          '🐎',
          style: TextStyle(
            fontSize: 56,
            color: widget.horse.color,
          ),
        );
      },
    );
  }
}