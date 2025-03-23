import processing.sound.*;

SoundFile sfxMenu;
SoundFile sfxTyped;
SoundFile sfxHighscores;
SoundFile sfxHighscoresTop;

PFont fntOrbitronRegular;
PFont fntOrbitronBold;
PFont fntOrbitronBlack;
PFont fntOCR_A;

GameState gameState;

final color GREEN = color(32, 255, 64);
final color RED = color(200, 10, 10);

Table highscores;

void setup() {
  //fullScreen();
  size(1800, 900);

  fntOrbitronRegular = createFont("fonts/Orbitron/Orbitron-Regular.ttf", 128);
  fntOrbitronBold = createFont("fonts/Orbitron/Orbitron-Bold.ttf", 128);
  fntOrbitronBlack = createFont("fonts/Orbitron/Orbitron-Black.ttf", 128);
  fntOCR_A = createFont("fonts/OCR_A/OCR_A.ttf", 128);

  sfxMenu = new SoundFile(this, "sfx/menu.wav");
  sfxTyped = new SoundFile(this, "sfx/typed.wav");
  sfxHighscores = new SoundFile(this, "sfx/highscores.wav");
  sfxHighscoresTop = new SoundFile(this, "sfx/highscores_top.wav");

  gameState = new GameState(0,
    new Scene_MainMenu(),
    new Scene_InGame(),
    new Scene_Score()
    );

  highscores = loadTable("data/highscores.csv", "header");
  highscores.setColumnType("score", Table.INT);
  highscores.trim();
  highscores.sortReverse("score");
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

void mouseWheel(MouseEvent event) {
  gameState.mouseWheelCurrentScene(event);
}

void keyPressed() {
  gameState.keyPressedCurrentScene();
}

void keyReleased() {
  gameState.keyReleasedCurrentScene();
}
