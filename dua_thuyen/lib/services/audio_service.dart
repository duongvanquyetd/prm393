import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class GameAudioService {
  GameAudioService._private();

  static final GameAudioService instance = GameAudioService._private();

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _horseRunPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  bool _isBackgroundPlaying = false;

  Future<void> playBackgroundMusic() async {
    if (_isBackgroundPlaying) return;

    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(0.35);
      await _bgPlayer.play(
        AssetSource('audios/nhacnenvuinhon.mp3'),
      );

      _isBackgroundPlaying = true;
      debugPrint('Đã phát nhạc nền');
    } catch (e) {
      debugPrint('Lỗi phát nhạc nền: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _bgPlayer.stop();
      _isBackgroundPlaying = false;
    } catch (e) {
      debugPrint('Lỗi dừng nhạc nền: $e');
    }
  }

  Future<void> playCountdownSound() async {
    try {
      await _effectPlayer.stop();
      await _effectPlayer.setVolume(1.0);
      await _effectPlayer.play(
        AssetSource('audios/dem_nguoc.mp3'),
      );
      debugPrint('Đã phát tiếng đếm ngược');
    } catch (e) {
      debugPrint('Lỗi phát tiếng đếm ngược: $e');
    }
  }

  Future<void> playHorseRunSound() async {
    try {
      await _horseRunPlayer.stop();
      await _horseRunPlayer.setReleaseMode(ReleaseMode.loop);
      await _horseRunPlayer.setVolume(0.85);
      await _horseRunPlayer.play(
        AssetSource('audios/tieng_chan_ngua.mp3'),
      );

      debugPrint('Đã phát tiếng chân ngựa');
    } catch (e) {
      debugPrint('Lỗi phát tiếng chân ngựa: $e');
    }
  }

  Future<void> stopHorseRunSound() async {
    try {
      await _horseRunPlayer.stop();
    } catch (e) {
      debugPrint('Lỗi dừng tiếng chân ngựa: $e');
    }
  }

  Future<void> playHorseNeighSound() async {
    try {
      await _effectPlayer.stop();
      await _effectPlayer.setVolume(1.0);
      await _effectPlayer.play(
        AssetSource('audios/tieng_ngua_hi.mp3'),
      );

      debugPrint('Đã phát tiếng ngựa hí');
    } catch (e) {
      debugPrint('Lỗi phát tiếng ngựa hí: $e');
    }
  }

  Future<void> playFireworkSound() async {
    try {
      await _effectPlayer.stop();
      await _effectPlayer.setVolume(1.0);
      await _effectPlayer.play(
        AssetSource('audios/phaohoa.mp3'),
      );

      debugPrint('Đã phát tiếng pháo hoa');
    } catch (e) {
      debugPrint('Lỗi phát tiếng pháo hoa: $e');
    }
  }

  Future<void> dispose() async {
    await _bgPlayer.dispose();
    await _horseRunPlayer.dispose();
    await _effectPlayer.dispose();
  }
}