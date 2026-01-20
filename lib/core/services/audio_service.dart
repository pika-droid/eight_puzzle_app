import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  Future<void> playMoveSound() async {
    if (_isMuted) return;
    try {
      // Create a temporary player for overlapping sounds
      final player = AudioPlayer();
      await player.play(AssetSource('audio/move.mp3'));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      // Ignore audio errors
    }
  }

  Future<void> playShuffleSound() async {
    if (_isMuted) return;
    try {
      await _player.play(AssetSource('audio/shuffle.mp3'));
    } catch (e) {
      // Ignore audio errors
    }
  }

  Future<void> playSolveSound() async {
    if (_isMuted) return;
    try {
      await _player.play(AssetSource('audio/solve.mp3'));
    } catch (e) {
      // Ignore audio errors
    }
  }
}
