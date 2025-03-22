import processing.sound.*;

SoundFile sfxMenu;

PFont fntOrbitron;

GameState gameState;

color GREEN = color(32, 255, 64);

void setup() {
  //fullScreen();
  size(1800, 900);

  fntOrbitron = createFont("fonts/Orbitron/Orbitron-Regular.ttf", 128);

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
