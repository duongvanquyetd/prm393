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

      // Ngựa bắt đầu ở bên phải và chạy sang trái
      left: startX - horse.position,

      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 70,
            child: Image.asset(
              horse.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  '🐎',
                  style: TextStyle(
                    fontSize: 56,
                    color: horse.color,
                  ),
                );
              },
            ),
          ),

          // Chạy sang trái thì bụi nằm phía sau, tức bên phải con ngựa
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