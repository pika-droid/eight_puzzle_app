import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal() {
    _initPool();
  }

  final AudioPlayer _mainPlayer = AudioPlayer();
  final List<AudioPlayer> _movePool = [];
  static const int _poolSize = 5;
  int _poolIndex = 0;

  bool _isMuted = false;

  bool get isMuted => _isMuted;

  void _initPool() {
    for (int i = 0; i < _poolSize; i++) {
      final player = AudioPlayer();
      player.setReleaseMode(ReleaseMode.stop);
      // Pre-load the source to reduce latency
      player.setSource(AssetSource('audio/move.mp3'));
      _movePool.add(player);
    }

    // Configure main player for low latency if possible
    _mainPlayer.setReleaseMode(ReleaseMode.stop);
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _stopAll();
    }
  }

  Future<void> playMoveSound() async {
    if (_isMuted) return;
    try {
      // Round-robin selection
      final player = _movePool[_poolIndex];
      _poolIndex = (_poolIndex + 1) % _poolSize;

      await player.stop();
      await player.resume(); // Resume the pre-loaded source
    } catch (e) {
      // Ignore audio errors
    }
  }

  Future<void> playShuffleSound() async {
    if (_isMuted) return;
    try {
      await _mainPlayer.stop();
      await _mainPlayer.play(AssetSource('audio/shuffle.mp3'));
    } catch (e) {
      // Ignore audio errors
    }
  }

  Future<void> playSolveSound() async {
    if (_isMuted) return;
    try {
      await _mainPlayer.stop();
      await _mainPlayer.play(AssetSource('audio/solve.mp3'));
    } catch (e) {
      // Ignore audio errors
    }
  }

  void _stopAll() {
    _mainPlayer.stop();
    for (final player in _movePool) {
      player.stop();
    }
  }

  void dispose() {
    _mainPlayer.dispose();
    for (final player in _movePool) {
      player.dispose();
    }
  }
}
