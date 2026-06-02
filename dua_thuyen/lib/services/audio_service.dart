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
  final AudioPlayer _wrongAnswerPlayer = AudioPlayer();

  bool _pausedForRace = false;
  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;

    try {
      await _bgPlayer.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );

      final effectContext = AudioContext(
        android: AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
      );

      await _countdownPlayer.setAudioContext(effectContext);
      await _neighPlayer.setAudioContext(effectContext);
      await _neighPlayer.setReleaseMode(ReleaseMode.release);
      await _neighPlayer.setVolume(0.9);
      await _neighPlayer.setSource(AssetSource('audios/tieng_ngua_hi.mp3'));

      await _fireworkPlayer.setAudioContext(effectContext);
      await _wrongAnswerPlayer.setAudioContext(effectContext);

      await _horseRunPlayer.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );

      _initialized = true;
      debugPrint('Audio service đã sẵn sàng');
    } catch (e) {
      debugPrint('Lỗi khởi tạo audio: $e');
    }
  }

  Future<void> _playEffect(
    AudioPlayer player,
    String assetPath, {
    double volume = 0.9,
    ReleaseMode releaseMode = ReleaseMode.release,
  }) async {
    await ensureInitialized();

    try {
      await player.stop();
      await player.setReleaseMode(releaseMode);
      await player.setVolume(volume);
      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Lỗi phát $assetPath: $e');
    }
  }

  Future<void> ensureBackgroundMusic() async {
    if (_pausedForRace) return;
    await ensureInitialized();

    try {
      if (_bgPlayer.state == PlayerState.playing) return;

      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(0.5);

      if (_bgPlayer.state == PlayerState.paused) {
        await _bgPlayer.resume();
      } else {
        await _bgPlayer.play(AssetSource('audios/nhacnenvuinhon.mp3'));
      }

      debugPrint('Đã phát nhạc nền');
    } catch (e) {
      debugPrint('Lỗi phát nhạc nền: $e');
    }
  }

  Future<void> pauseForRace() async {
    _pausedForRace = true;

    try {
      await _bgPlayer.pause();
      debugPrint('Đã tắt nhạc nền (màn đua)');
    } catch (e) {
      debugPrint('Lỗi tắt nhạc nền: $e');
    }
  }

  Future<void> resumeAfterRace() async {
    _pausedForRace = false;
    await ensureBackgroundMusic();
    debugPrint('Đã bật lại nhạc nền');
  }

  Future<void> playBackgroundMusic() => ensureBackgroundMusic();

  Future<void> stopBackgroundMusic() async {
    try {
      await _bgPlayer.stop();
      debugPrint('Đã dừng nhạc nền');
    } catch (e) {
      debugPrint('Lỗi dừng nhạc nền: $e');
    }
  }

  Future<void> restartBackgroundMusic() async {
    if (_pausedForRace) return;
    await ensureInitialized();

    try {
      await _bgPlayer.stop();
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(0.5);
      await _bgPlayer.play(AssetSource('audios/nhacnenvuinhon.mp3'));
      debugPrint('Đã restart nhạc nền');
    } catch (e) {
      debugPrint('Lỗi restart nhạc nền: $e');
    }
  }

  Future<void> playCountdownSound() {
    return _playEffect(_countdownPlayer, 'audios/dem_nguoc.mp3');
  }

  Future<void> playHorseRunSound() {
    return _playEffect(
      _horseRunPlayer,
      'audios/tieng_chan_ngua.mp3',
      volume: 0.85,
      releaseMode: ReleaseMode.loop,
    );
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
    await ensureInitialized();

    try {
      final state = _neighPlayer.state;

      if (state == PlayerState.playing) {
        await _neighPlayer.seek(Duration.zero);
        return;
      }

      if (state == PlayerState.paused) {
        await _neighPlayer.seek(Duration.zero);
        await _neighPlayer.resume();
        return;
      }

      await _neighPlayer.play(AssetSource('audios/tieng_ngua_hi.mp3'));
    } catch (e) {
      debugPrint('Lỗi phát tiếng ngựa hí: $e');
    }
  }

  Future<void> playFireworkSound() {
    return _playEffect(_fireworkPlayer, 'audios/phaohoa.mp3');
  }

  Future<void> playWrongAnswerSound() {
    return _playEffect(
      _wrongAnswerPlayer,
      'audios/nhac_tra_loi_sai-www_tiengdong_com.mp3',
    );
  }

  Future<void> stopAllEffects() async {
    await Future.wait([
      _countdownPlayer.stop(),
      _neighPlayer.stop(),
      _fireworkPlayer.stop(),
      _wrongAnswerPlayer.stop(),
      _horseRunPlayer.stop(),
    ]);
  }

  Future<void> dispose() async {
    await _bgPlayer.dispose();
    await _horseRunPlayer.dispose();
    await _countdownPlayer.dispose();
    await _neighPlayer.dispose();
    await _fireworkPlayer.dispose();
    await _wrongAnswerPlayer.dispose();
  }
}
