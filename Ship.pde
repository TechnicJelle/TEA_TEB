class Ship {
  PVector pos;
  PVector vel;
  PVector acc;

  float scale;
  float fuel;

  Ship(PVector p, PVector v, float s) {
    pos = p;
    vel = v;
    acc = new PVector(0, 0);
    scale = s;
    fuel = 100;
  }
  
  void draw() {
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    rotate(this.vel.heading() - HALF_PI);
    scale(this.scale);
    stroke(100, 100, 100);
    strokeWeight(1);
    fill(200, 200, 200);

    beginShape();
      vertex(-1, 14);
      vertex(1, 14);
      vertex(3, 10);
      vertex(3, 4);
      vertex(5, 0);
      vertex(5, -6);
      vertex(1, -8);
      vertex(-1, -8);
      vertex(-5, -6);
      vertex(-5, 0);
      vertex(-3, 4);
      vertex(-3, 10);
    endShape(CLOSE);

    beginShape(LINES);
      vertex(-5, 4);
      vertex(-5, -8);
      vertex(5, 4);
      vertex(5, -8);

      vertex(-3, 0);
      vertex(-3, -5);
      vertex(3, 0);
      vertex(3, -5);
    endShape();

    stroke(150, 10, 10);
    strokeWeight(2);
    beginShape(LINES);
      vertex(-2, 9);
      vertex(2, 9);

      vertex(-2, 5);
      vertex(2, 5);
    endShape();
    stroke(100, 100, 100);
    strokeWeight(1);
    beginShape(LINES);
      vertex(-3, 12);
      vertex(-3, 4);

      vertex(3, 12);
      vertex(3, 4);
    endShape();

    popMatrix();
  }
}

int continuation_in_space(PVector pos, PVector vel, PVector acc) {
  acc = new PVector(0, 0);

  int soi_planet = closest_soi(pos);
    
  //apply appropriate forces
  Planet soi = planets.get(soi_planet);
  PVector difference = PVector.sub(pos, soi.pos);
  float sq_distance = 1 + sq(difference.mag());
  acc.add(difference.normalize().mult(-G * soi.mass / sq_distance));
  vel.add(PVector.mult(acc, dt));
  pos.add(PVector.mult(vel, dt));
  
  //limit velocity
  if (vel.mag() > velocity_limit) {
    vel.mult(velocity_limit / vel.mag());
  }

  // wall bounce
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
  return soi_planet;
}

void actual_trajectory_calculation() {  
  PVector trajectory_pos = ship.pos.copy();
  PVector trajectory_vel = ship.vel.copy();
  PVector trajectory_acc = new PVector(0, 0);

  for (int i = 0; i < trajectory_lookahead; i++) { /* trajectory for-loop */
    int soi_planet = continuation_in_space(trajectory_pos, trajectory_vel, trajectory_acc);
  
    trajectory[i] = trajectory_pos.copy();
    trajectory_sois[i] = soi_planet;
  } /* trajectory for-loop */
  
  going_to_die = true;
  //test if trajectory gets stuck
  for (int v = trajectory_lookahead - trajectory_lookahead/3; v < trajectory_lookahead; v++) {
    if (trajectory_sois[v] != trajectory_sois[v-1]) {
      going_to_die = false;
    }
  }
}
