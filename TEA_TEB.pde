import processing.sound.*;

SoundFile sfxMenu;

PFont fntOrbitronRegular;
PFont fntOrbitronBold;
PFont fntOrbitronBlack;

GameState gameState;

final color GREEN = color(32, 255, 64);
final color RED = color(200, 10, 10);

void setup() {
  //fullScreen();
  size(1800, 900);

  fntOrbitronRegular = createFont("fonts/Orbitron/Orbitron-Regular.ttf", 128);
  fntOrbitronBold = createFont("fonts/Orbitron/Orbitron-Bold.ttf", 128);
  fntOrbitronBlack = createFont("fonts/Orbitron/Orbitron-Black.ttf", 128);


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
