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
  List<Scene> internalScenes;
  int currentScene;
  int defaultScene;
  boolean goToNextScene = false;

  GameState(int defaultScene, Scene... scenes) {
    internalScenes = List.of(scenes);
    this.defaultScene = defaultScene;
    assert internalScenes.size() > 0;
    currentScene = 0;
  }

  Scene getCurrentScene() {
    return internalScenes.get(currentScene);
  }

  void stepCurrentScene() {
    if (goToNextScene) {
      sfxMenu.play();
      goToNextScene = false;
      getCurrentScene().cleanup();
      currentScene++;
      if (currentScene > internalScenes.size()-1)
        currentScene = defaultScene;

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
    goToNextScene = true;
  }
}
