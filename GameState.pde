import java.util.List;

interface Scene {
  void init();
  void step();
  void mousePressed();
  void mouseDragged();
  void mouseReleased();
  void keyPressed();
  void keyReleased();
  void cleanup();
}

class GameState {
  List<Scene> _internalScenes;
  int _currentScene;
  int _defaultScene;
  boolean _goToNextScene = false;

  GameState(int defaultScene, Scene... scenes) {
    _internalScenes = List.of(scenes);
    this._defaultScene = defaultScene;
    assert _internalScenes.size() > 0;
    _currentScene = 0;
  }

  Scene getCurrentScene() {
    return _internalScenes.get(_currentScene);
  }

  void stepCurrentScene() {
    if (_goToNextScene) {
      sfxMenu.play();
      _goToNextScene = false;
      getCurrentScene().cleanup();
      _currentScene++;
      if (_currentScene > _internalScenes.size()-1)
        _currentScene = _defaultScene;

      getCurrentScene().init();
      return;
    }
    getCurrentScene().step();
  }

  void mousePressedCurrentScene() {
    getCurrentScene().mousePressed();
  }

  void mouseDraggedCurrentScene() {
    getCurrentScene().mouseDragged();
  }

  void mouseReleasedCurrentScene() {
    getCurrentScene().mouseReleased();
  }

  void keyPressedCurrentScene() {
    getCurrentScene().keyPressed();
  }

  void keyReleasedCurrentScene() {
    getCurrentScene().keyReleased();
  }

  void nextScene() {
    _goToNextScene = true;
  }
}
