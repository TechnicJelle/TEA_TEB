class Ship {
  PVector pos;
  PVector vel;
  PVector acc;

  float radius;
  color col;

  Ship(PVector p, PVector v, float r, color c) {
    pos = p;
    vel = v;
    acc = new PVector(0, 0);
    radius = r;
    col = c;
  }
}

void take_care_of_wall_bounce(PVector pos, PVector vel) {
  if (pos.x > width-right_border || pos.x < left_border) {
    if (pos.x > width-right_border) {
      pos.x = width-right_border;
    } else {
      pos.x = left_border;
    }
    vel.x *= -1;
  }
  if (pos.y > height-bottom_border || pos.y < top_border) {
    if (pos.y > height-bottom_border) {
      pos.y = height-bottom_border;
    } else {
      pos.y = top_border;
    }
    vel.y *= -1;
  }
}
