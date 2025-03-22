import processing.sound.*;

SoundFile sfxMenu;

GameState gameState;

void setup() {
  //fullScreen();
  size(1800, 900);

  sfxMenu = new SoundFile(this, "sfx/menu.wav");

  gameState = new GameState(0,
    new Scene_MainMenu(),
    new Scene_InGame()
    );
}

void draw() {
  gameState.stepCurrentScene();
}

void mousePressed() {
  gameState.mousePressedCurrentScene();
}

void mouseDragged() {
  gameState.mouseDraggedCurrentScene();
}

void mouseReleased() {
  gameState.mouseReleasedCurrentScene();
}

void keyPressed() {
  gameState.keyPressedCurrentScene();
}

void keyReleased() {
  gameState.keyReleasedCurrentScene();
}
