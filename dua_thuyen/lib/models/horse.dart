import 'package:flutter/material.dart';

class Horse {
  final int id;
  final String name;
  final String imagePath;
  final Color color;
  final List<String> frames;

  double position;
  bool finished;
  double progress;
  Horse({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.color,
    this.position = 0,
    this.finished = false,
    required this.frames,
    this.progress = 0,
  });

  void reset() {
    position = 0;
    finished = false;
  }
}