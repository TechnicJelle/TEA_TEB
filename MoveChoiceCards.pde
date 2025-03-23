abstract class MoveChoiceCard {
  float x, y;
  float w, h;
  boolean hovering = false;

  MoveChoiceCard(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void step() {
    hovering = mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;

    rect(x, y, w, h, 5);

    if (hovering) {
      if (mousePressed) {
        fill(200, 200);
      } else {
        fill(200, 140);
      }
      rect(x, y, w, h, 5);
    }
  }

  abstract void checkClick();
}

MoveType moveType = MoveType.FLYING;
enum MoveType {
  FLYING, STEER, EXPLODE_PLANET, LOCK_IN
}

class SteerChoiceCard extends MoveChoiceCard {
  PImage tex;

  SteerChoiceCard(float x, float y, float w, float h) {
    super(x, y, w, h);
    tex = loadImage("data/tex/split_road.png");
  }

  void step() {
    fill(255);
    super.step();
    imageMode(CENTER);
    image(tex, x+w/2, y+h/2);
    imageMode(CORNER);
  }

  void checkClick() {
    if (!hovering) return;
    moveType = MoveType.STEER;
  }
}

class ExplodePlanetChoiceCard extends MoveChoiceCard {
  PImage tex;

  ExplodePlanetChoiceCard(float x, float y, float w, float h) {
    super(x, y, w, h);
    tex = loadImage("data/tex/fragmentation.png");
  }

  void step() {
    fill(255, 0, 0);
    super.step();
    imageMode(CENTER);
    image(tex, x+w/2, y+h/2);
    imageMode(CORNER);
  }

  void checkClick() {
    if (!hovering) return;
    moveType = MoveType.EXPLODE_PLANET;
  }
}

class LockInChoiceCard extends MoveChoiceCard {
  PImage tex;

  LockInChoiceCard(float x, float y, float w, float h) {
    super(x, y, w, h);
    tex = loadImage("data/tex/nyoom.png");
  }

  void step() {
    fill(0, 255, 255);
    super.step();
    imageMode(CENTER);
    image(tex, x+w/2, y+h/2);
    imageMode(CORNER);
  }

  void checkClick() {
    if (!hovering) return;
    moveType = MoveType.LOCK_IN;
  }
}
