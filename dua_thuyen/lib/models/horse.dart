import 'package:flutter/material.dart';

class Horse {
  final int id;
  final String name;
  final String imagePath;
  final Color color;

  double position;
  bool finished;

  Horse({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.color,
    this.position = 0,
    this.finished = false,
  });

  void reset() {
    position = 0;
    finished = false;
  }
}