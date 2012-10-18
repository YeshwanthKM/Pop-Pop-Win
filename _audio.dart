class _Audio {
  static const List<String> _audioNames =
      const ['Pop0', 'Pop1', 'Pop2', 'Pop3', 'Pop4', 'Pop5', 'Pop6', 'Pop7', 'Pop8',
             'Bomb0', 'Bomb1', 'Bomb2', 'Bomb3', 'Bomb4',
             GameAudio.THROW_DART, GameAudio.FLAG, GameAudio.UNFLAG, GameAudio.CLICK, GameAudio.WIN];

  final AudioLoader _audioLoader;
  final Map<String, AudioBuffer> _buffers = new Map();

  factory _Audio() {
    if(_supportsAudio) {
      final audioContext = new AudioContext();
      final loader = new AudioLoader(audioContext, _getAudioPaths(_audioNames));
      return new _Audio._internal(loader);
    } else {
      return new _Audio._disabled();
    }
  }

  _Audio._disabled() : this._audioLoader = null;

  _Audio._internal(this._audioLoader) {
    // TODO: less than ideal. Binding to event handlers defined in game.dart
    // re-expose events? Take in handlers in ctor? Hmm...
    _audioLoader.progress.add(_onProgress);
    _audioLoader.loaded.add(_onLoaded);
    _audioLoader.loaded.add(_onLoad);
    GameAudio.audioEvent.add(_playAudio);
    _audioLoader.load();
  }

  int get completedBytes {
    if(_audioLoader == null) {
      return 0;
    } else {
      return _audioLoader.completedBytes;
    }
  }

  int get totalBytes {
    if(_audioLoader == null) {
      return 0;
    } else {
      return _audioLoader.totalBytes;
    }
  }

  bool get done {
    if(_audioLoader == null) {
      return true;
    } else {
      return _audioLoader.state == ResourceLoader.StateLoaded;
    }
  }

  AudioContext get _audioContext {
    if(_audioLoader != null) {
      return _audioLoader.context;
    } else {
      return null;
    }
  }

  void _onLoad(args) {
    assert(_buffers.length == 0);
    for(final name in _audioNames) {
      final path = _getAudioPath(name);
      _buffers[name] = _audioLoader.getResource(path);
    }
  }

  void _playAudio(String name) {
    switch(name) {
      case GameAudio.POP:
        final i = rnd.nextInt(8);
        name = '${GameAudio.POP}$i';
        break;
      case GameAudio.BOMB:
        final i = rnd.nextInt(4);
        name = '${GameAudio.BOMB}$i';
        break;
    }
    _playAudioCore(name);
  }

  void _playAudioCore(String name) {
    if(_audioContext != null) {
      var source = _audioContext.createBufferSource();
      final buffer = _buffers[name];
      assert(buffer != null);
      source.buffer = buffer;
      source.connect(_audioContext.destination, 0);
      source.start(0);
    }
  }

  static bool get _supportsAudio {
    try {
      final isWebKit = window.clientInformation.userAgent.contains("WebKit");
      return isWebKit;
    } catch (e) {
      return false;
    }
  }

  static String _getAudioPath(String name) => 'audio/$name.m4a';

  static Iterable<String> _getAudioPaths(Iterable<String> names) {
    return $(names).map(_getAudioPath);
  }
}
