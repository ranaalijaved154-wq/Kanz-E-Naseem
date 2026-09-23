import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio_model.dart';

class AudioPlayerService {
  // Singleton pattern
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  final AudioPlayer _player = AudioPlayer();

  final ValueNotifier<AudioModel?> currentAudioNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<double> speedNotifier = ValueNotifier(1.0);

  AudioPlayerService._internal() {
    // Listen to player state changes
    _player.playerStateStream.listen((state) {
      isPlayingNotifier.value = state.playing;
      isLoadingNotifier.value = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;

      if (state.processingState == ProcessingState.completed) {
        // Track completed
        _player.seek(Duration.zero);
        _player.pause();
      }
    });

    _player.speedStream.listen((speed) {
      speedNotifier.value = speed;
    });
  }

  AudioPlayer get player => _player;
  AudioModel? get currentAudio => currentAudioNotifier.value;
  bool get isPlaying => isPlayingNotifier.value;
  bool get hasActiveAudio => currentAudioNotifier.value != null;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Play a selected audio model
  Future<void> playAudio(AudioModel audio) async {
    // If the same audio is already loaded and paused, just resume
    if (currentAudioNotifier.value?.id == audio.id) {
      if (!isPlaying) {
        await _player.play();
      }
      return;
    }

    try {
      isLoadingNotifier.value = true;
      currentAudioNotifier.value = audio;

      await _player.stop();
      await _player.setUrl(audio.fileUrl);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      isLoadingNotifier.value = false;
    }
  }

  /// Toggle Play / Pause
  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  /// Pause current audio
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _player.play();
  }

  /// Seek to specific position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Seek forward by seconds (e.g. +10s)
  Future<void> seekForward({int seconds = 10}) async {
    final currentPos = _player.position;
    final totalDuration = _player.duration ?? Duration.zero;
    final target = currentPos + Duration(seconds: seconds);
    if (target < totalDuration) {
      await _player.seek(target);
    } else {
      await _player.seek(totalDuration);
    }
  }

  /// Seek backward by seconds (e.g. -10s)
  Future<void> seekBackward({int seconds = 10}) async {
    final currentPos = _player.position;
    final target = currentPos - Duration(seconds: seconds);
    if (target > Duration.zero) {
      await _player.seek(target);
    } else {
      await _player.seek(Duration.zero);
    }
  }

  /// Set Playback Speed (e.g. 0.75, 1.0, 1.25, 1.5, 2.0)
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// Stop & close player
  Future<void> stop() async {
    await _player.stop();
    currentAudioNotifier.value = null;
  }

  void dispose() {
    _player.dispose();
  }
}
