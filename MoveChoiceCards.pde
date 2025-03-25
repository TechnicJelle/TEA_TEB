abstract class MoveChoiceCard {
  float x, y;
  float w, h;
  boolean hovering = false;
  String explainer;

  MoveChoiceCard(float x, float y, float w, float h, String e) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.explainer = e;
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

      fill(100);
      textFont(fntOrbitronRegular);
      textSize(32);
      float tw = textWidth(explainer) + 10;
      rect(x + w/2 - tw/2, y - h/4 - 36, tw, 36, 5);
      fill(GREEN);
      text(explainer, x + w/2, y - h/4);
    }
  }

  abstract void checkClick();
}

MoveType moveType = MoveType.FLYING;
enum MoveType {
  FLYING, STEER, EXPLODE_PLANET, COAST
}

class SteerChoiceCard extends MoveChoiceCard {
  PImage tex;

  SteerChoiceCard(float x, float y, float w, float h) {
    super(x, y, w, h, "Steer (1): Adjust the movement of the ship");
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
    super(x, y, w, h, "Explode (2): a planet of choice");
    tex = loadImage("data/tex/fragmentation.png");
  }

  void step() {
    if (canExplodePlanet()) {
      fill(255, 0, 0);
      super.step();
    } else {
      fill(50);
      rect(x, y, w, h, 5);
      tint(100);
    }
    imageMode(CENTER);
    image(tex, x+w/2, y+h/2);
    noTint();
    imageMode(CORNER);
  }

  void checkClick() {
    if (!hovering) return;
    if (!canExplodePlanet()) return;
    moveType = MoveType.EXPLODE_PLANET;
  }
}

class CoastChoiceCard extends MoveChoiceCard {
  PImage tex;

  CoastChoiceCard(float x, float y, float w, float h) {
    super(x, y, w, h, "Coast (3): Move a pre-set amount of cells, and regain some fuel");
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
    moveType = MoveType.COAST;
  }
}
