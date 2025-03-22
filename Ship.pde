class Ship {
  PVector pos;
  PVector vel;
  PVector acc;

  float radius;
  color col;
  float fuel;

  Ship(PVector p, PVector v, float r, color c) {
    pos = p;
    vel = v;
    acc = new PVector(0, 0);
    radius = r;
    col = c;
    fuel = 100;
  }
}

int continuation_in_space(PVector pos, PVector vel, PVector acc) {
  acc = new PVector(0, 0);
  float largest_grav_force = 0;
  int soi_planet = last_soi_planet;  

  for (int j = 0; j < planets.size(); j++) {
    Planet p = planets.get(j);
  
    PVector difference = PVector.sub(pos, p.pos);
    float sq_distance = sq(difference.mag());
    float gravitational_force = G * p.mass / sq_distance;
  
    //if bigger, set new soi
    if (gravitational_force > largest_grav_force) {
      largest_grav_force = gravitational_force;
      soi_planet = j;
    }
  }
    
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
