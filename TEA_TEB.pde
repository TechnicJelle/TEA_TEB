import processing.sound.*;

ArrayList<Planet> planets;

PVector ship_pos;
PVector ship_vel = new PVector(-5, 0);
PVector ship_acc = new PVector(0, 0);

float ship_rad = 15;
float dt = 0.05;
float G = 5;
float velocity_limit = 25;

int soi_planet = 0;
int last_soi_planet = 0;

int left_border = 100;
int right_border = 100;
int top_border = 50;
int bottom_border = 200;
float ship_exclusion_radius = 100;

void setup() {
  //fullScreen();
  size(1800, 900);
  ship_pos = new PVector(19 * width / 20, height / 2);

  generate_all_planets_with_constraints();
  draw_voronoi_to_background();
}

void draw() {
  image(grBkgrVoronoi, 0, 0);

  // update ship position based on gravity


  for (int i = 0; i < 10; i++) {
    ship_acc = new PVector(0, 0);
    float largest_grav_force = 0;

    for (int j = 0; j < planets.size(); j++) {
      Planet p = planets.get(j);

      PVector difference = PVector.sub(ship_pos, p.pos);
      float sq_distance = sq(difference.mag());
      float gravitational_force = G * p.mass / sq_distance;

      //if bigger, set new soi
      if (gravitational_force > largest_grav_force) {
        largest_grav_force = gravitational_force;
        soi_planet = j;
      }
    }

    if (soi_planet != last_soi_planet) {
      noLoop();
      last_soi_planet = soi_planet;
      break;
    }


    //do the soi stuff
    Planet soi = planets.get(soi_planet);
    PVector difference = PVector.sub(ship_pos, soi.pos);
    float sq_distance = 1 + sq(difference.mag());
    ship_acc.add(difference.normalize().mult(-G * soi.mass / sq_distance));

    //limit velocity
    if (ship_vel.mag() > velocity_limit) {
      ship_vel.mult(velocity_limit / ship_vel.mag());
    }


    ship_vel.add(PVector.mult(ship_acc, dt));
    ship_pos.add(PVector.mult(ship_vel, dt));

    //support wall bouncing
    if (ship_pos.x > width-right_border || ship_pos.x < left_border) {
      if (ship_pos.x > width-right_border) {
        ship_pos.x = width-right_border;
      } else {
        ship_pos.x = left_border;
      }
      ship_vel.x *= -1;
    }
    if (ship_pos.y > height-bottom_border || ship_pos.y < top_border) {
      if (ship_pos.y > height-bottom_border) {
        ship_pos.y = height-bottom_border;
      } else {
        ship_pos.y = top_border;
      }
      ship_vel.y *= -1;
    }
  }

  //draw ship
  fill(color(0, 255, 255));
  circle(ship_pos.x, ship_pos.y, ship_rad);

  //draw planets
  for (Planet p : planets) {
    noStroke();
    fill(p.col);
    circle(p.pos.x, p.pos.y, p.radius);
  }

  Planet soi = planets.get(soi_planet);
  fill(0, 255, 0);
  noStroke();
  circle(soi.pos.x, soi.pos.y, soi.radius);
}

void mousePressed() {
  loop();
}
