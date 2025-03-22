class Scene_MainMenu implements Scene {
  void init() {
  }

  void update() {
  }

  void render() {
    background(0);
    textAlign(CENTER, CENTER);
    textSize(32);
    fill(255);
    text("Click anywhere to start...", width/2f, height/2f);
  }

  void mousePressed() {
    gameState.nextScene();
  }

  void mouseDragged() {
  }

  void mouseReleased() {
  }

  void keyPressed() {
  }

  void keyReleased() {
  }

  void cleanup() {
  }
}
