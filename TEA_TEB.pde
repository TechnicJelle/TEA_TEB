import processing.sound.*;

SoundFile sfxTestSound1;

void setup() {
  size(400, 400);
  
  sfxTestSound1 = new SoundFile(this, "sfx/test_sound1.wav");
}

void draw() {
}

void mousePressed() {
  sfxTestSound1.play();
}
