class Scene_MainMenu implements Scene {
  void init() {
  }

  void step() {
    background(0);
    textAlign(CENTER, CENTER);
    textFont(fntOrbitron);
    fill(GREEN);

    textSize(128);
    text("TEA_TEB", width/2f, height*0.2);

    textSize(32);
    text("Click anywhere to start...", width/2f, height*0.7);
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
