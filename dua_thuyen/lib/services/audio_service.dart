import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class GameAudioService {
  GameAudioService._private();

  static final GameAudioService instance = GameAudioService._private();

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _horseRunPlayer = AudioPlayer();

  final AudioPlayer _countdownPlayer = AudioPlayer();
  final AudioPlayer _neighPlayer = AudioPlayer();
  final AudioPlayer _fireworkPlayer = AudioPlayer();

  Future<void> playBackgroundMusic() async {
    try {
      if (_bgPlayer.state == PlayerState.playing) return;

      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(0.35);
      await _bgPlayer.play(
        AssetSource('audios/nhacnenvuinhon.mp3'),
      );

      debugPrint('Đã phát nhạc nền');
    } catch (e) {
      debugPrint('Lỗi phát nhạc nền: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      if (_bgPlayer.state == PlayerState.playing) {
        await _bgPlayer.pause();
      }

      debugPrint('Đã pause nhạc nền');
    } catch (e) {
      debugPrint('Lỗi pause nhạc nền: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    try {
      if (_bgPlayer.state == PlayerState.playing) return;

      if (_bgPlayer.state == PlayerState.paused) {
        await _bgPlayer.resume();
      } else {
        await playBackgroundMusic();
      }

      debugPrint('Đã resume nhạc nền');
    } catch (e) {
      debugPrint('Lỗi resume nhạc nền: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _bgPlayer.stop();
      debugPrint('Đã dừng nhạc nền');
    } catch (e) {
      debugPrint('Lỗi dừng nhạc nền: $e');
    }
  }

  Future<void> playCountdownSound() async {
    try {
      await _countdownPlayer.stop();
      await _countdownPlayer.setVolume(0.9);
      await _countdownPlayer.play(
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
      await _horseRunPlayer.setVolume(0.75);
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
      debugPrint('Đã dừng tiếng chân ngựa');
    } catch (e) {
      debugPrint('Lỗi dừng tiếng chân ngựa: $e');
    }
  }

  Future<void> playHorseNeighSound() async {
    try {
      await _neighPlayer.stop();
      await _neighPlayer.setVolume(0.9);
      await _neighPlayer.play(
        AssetSource('audios/tieng_ngua_hi.mp3'),
      );

      debugPrint('Đã phát tiếng ngựa hí');
    } catch (e) {
      debugPrint('Lỗi phát tiếng ngựa hí: $e');
    }
  }

  Future<void> playFireworkSound() async {
    try {
      await _fireworkPlayer.stop();
      await _fireworkPlayer.setVolume(0.9);
      await _fireworkPlayer.play(
        AssetSource('audios/phaohoa.mp3'),
      );

      debugPrint('Đã phát tiếng pháo hoa');
    } catch (e) {
      debugPrint('Lỗi phát tiếng pháo hoa: $e');
    }
  }

  Future<void> stopAllEffects() async {
    await _countdownPlayer.stop();
    await _neighPlayer.stop();
    await _fireworkPlayer.stop();
    await _horseRunPlayer.stop();
  }

  Future<void> dispose() async {
    await _bgPlayer.dispose();
    await _horseRunPlayer.dispose();
    await _countdownPlayer.dispose();
    await _neighPlayer.dispose();
    await _fireworkPlayer.dispose();
  }
  Future<void> restartBackgroundMusic() async {
    try {
      await _bgPlayer.stop();

      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(0.35);

      await _bgPlayer.play(
        AssetSource('audios/nhacnenvuinhon.mp3'),
      );

      debugPrint('Đã restart nhạc nền');
    } catch (e) {
      debugPrint('Lỗi restart nhạc nền: $e');
    }
  }
}