class Scene_MainMenu implements Scene {
  void init() {
  }

  void step() {
    background(0);
    textAlign(CENTER, CENTER);
    fill(GREEN);

    textFont(fntOrbitronBlack);
    textSize(128);
    text("TEA_TEB", width/2f, height*0.2);

    textFont(fntOrbitronRegular);
    textSize(32);
    text("Press space or click to start...", width/2f, height*0.7);
  }

  void mousePressed() {
  }

  void mouseDragged() {
  }

  void mouseReleased() {
    gameState.nextScene();
  }

  void mouseWheel(MouseEvent event) {
  }

  void keyPressed() {
  }

  void keyReleased() {
    gameState.nextScene();
  }

  void cleanup() {
  }
}
