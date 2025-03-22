import processing.sound.*;

ArrayList<Planet> planets;

PGraphics grBkgrVoronoi;

Ship ship;

float dt = 0.05;
float G = 5;
float velocity_limit = 25;

int soi_planet = 0;
int last_soi_planet = 0;

int left_border = 100;
int right_border = 100;
int top_border = 50;
int bottom_border = 200;

int trajectory_lookahead = 2500;

float ship_exclusion_radius = 100;

void setup() {
  //fullScreen();
  size(1800, 900);
  
  ship = new Ship(new PVector(19 * width / 20, height / 2), new PVector(-5, 0), 15, color(0, 255, 255));

  ArrayList<Planet> initial_planets = new ArrayList<Planet>();
  planets = new ArrayList<Planet>();


  for (int i = 0; i < 250; i++) {
    initial_planets.add(new Planet(new PVector(random(width), random(height)), random(1, 200), random(2, 20), color(255)));
  }

  for (int i = 0; i < initial_planets.size(); i++) {
    Planet p = initial_planets.get(i);
    boolean touching = false;
    if (p.pos.x < left_border || width - right_border < p.pos.x) continue;
    if (p.pos.y < top_border || height - bottom_border < p.pos.y) continue;
    if (PVector.dist(p.pos, ship.pos) < ship_exclusion_radius) continue;
    for (int j = i+1; j < initial_planets.size(); j++) {
      Planet q = initial_planets.get(j);

      if (PVector.dist(p.pos, q.pos) < (p.radius + q.radius)) {
        touching = true;
      }
    }
    if (!touching) planets.add(p);
  }


  //do img array stuff
  grBkgrVoronoi = createGraphics(width, height);
  grBkgrVoronoi.beginDraw();
  grBkgrVoronoi.background(0);

  grBkgrVoronoi.loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float closest_1 = Float.MAX_VALUE;
      PVector closest_vec_1 = new PVector(Float.MAX_VALUE, Float.MAX_VALUE);
      float closest_2 = Float.MAX_VALUE - 1;
      PVector closest_vec_2 = new PVector(Float.MAX_VALUE, Float.MAX_VALUE);

      for (Planet p : planets) {
        float distance = sq(dist(x, y, p.pos.x, p.pos.y))/p.mass;

        if (distance < closest_2) {
          closest_2 = distance;
          closest_vec_2 = p.pos;
          //          closest_vec_2 = new PVector(p.pos.x - x, p.pos.y - y);
        }

        if (closest_2 < closest_1) {
          float temp = closest_2;
          closest_2 = closest_1;
          closest_1 = temp;

          PVector tempv = closest_vec_2;
          closest_vec_2 = closest_vec_1;
          closest_vec_1 = tempv;
        }
      }

      float dist_to_line;
      {
        PVector line_between_planets = PVector.sub(closest_vec_2, closest_vec_1);
        //PVector point_between_planets = PVector.add(closest_vec_1, PVector.div(line_between_planets, 2));
        //PVector point = new PVector((float)x, (float)y);
        //PVector rpoint = PVector.sub(point_between_planets, point);
        //dist_to_line = PVector.dot(rpoint, line_between_planets)/line_between_planets.mag();
        dist_to_line = (closest_2 - closest_1)/line_between_planets.mag();
      }
      if (dist_to_line < 0.05) {
        //make line
        grBkgrVoronoi.pixels[x + y * width] = color(0);
      } else {
        //make gradient
        grBkgrVoronoi.pixels[x + y * width] = color(260 / (1 + closest_1/100), 10, 50);
      }
    }
  }
  grBkgrVoronoi.updatePixels();
  grBkgrVoronoi.endDraw();

  //for (Planet p : planets) {
  //  circle(p.pos.x, p.pos.y, p.radius);
  //}
}

void draw() {
  image(grBkgrVoronoi, 0, 0);

  // update ship position based on gravity


  for (int i = 0; i < 10; i++) {
    ship.acc = new PVector(0, 0);
    float largest_grav_force = 0;

    for (int j = 0; j < planets.size(); j++) {
      Planet p = planets.get(j);

      PVector difference = PVector.sub(ship.pos, p.pos);
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
    PVector difference = PVector.sub(ship.pos, soi.pos);
    float sq_distance = 1 + sq(difference.mag());
    ship.acc.add(difference.normalize().mult(-G * soi.mass / sq_distance));
    ship.vel.add(PVector.mult(ship.acc, dt));
    ship.pos.add(PVector.mult(ship.vel, dt));

    //limit velocity
    if (ship.vel.mag() > velocity_limit) {
      ship.vel.mult(velocity_limit / ship.vel.mag());
    }

    //support wall bouncing
    if (ship.pos.x > width-right_border || ship.pos.x < left_border) {
      if (ship.pos.x > width-right_border) {
        ship.pos.x = width-right_border;
      } else {
        ship.pos.x = left_border;
      }
      ship.vel.x *= -1;
    }
    if (ship.pos.y > height-bottom_border || ship.pos.y < top_border) {
      if (ship.pos.y > height-bottom_border) {
        ship.pos.y = height-bottom_border;
      } else {
        ship.pos.y = top_border;
      }
      ship.vel.y *= -1;
    }
  }

  PVector trajectory_pos = ship.pos.copy();
  PVector trajectory_vel = ship.vel.copy();
  PVector trajectory_acc;

  PVector[] trajectory = new PVector[trajectory_lookahead];

  // for the trajectory stuff
  for (int i = 0; i < trajectory_lookahead; i++) {
    trajectory_acc = new PVector(0, 0);
    float largest_grav_force = 0;

    for (int j = 0; j < planets.size(); j++) {
      Planet p = planets.get(j);

      PVector difference = PVector.sub(trajectory_pos, p.pos);
      float sq_distance = sq(difference.mag());
      float gravitational_force = G * p.mass / sq_distance;

      //if bigger, set new soi
      if (gravitational_force > largest_grav_force) {
        largest_grav_force = gravitational_force;
        soi_planet = j;
      }
    }

    //do the soi stuff
    Planet soi = planets.get(soi_planet);
    PVector difference = PVector.sub(trajectory_pos, soi.pos);
    float sq_distance = 1 + sq(difference.mag());
    trajectory_acc.add(difference.normalize().mult(-G * soi.mass / sq_distance));
    trajectory_vel.add(PVector.mult(trajectory_acc, dt));
    trajectory_pos.add(PVector.mult(trajectory_vel, dt));

    //limit velocity
    if (trajectory_vel.mag() > velocity_limit) {
      trajectory_vel.mult(velocity_limit / trajectory_vel.mag());
    }

    //support wall bouncing
    if (trajectory_pos.x > width-right_border || trajectory_pos.x < left_border) {
      if (trajectory_pos.x > width-right_border) {
        trajectory_pos.x = width-right_border;
      } else {
        trajectory_pos.x = left_border;
      }
      trajectory_vel.x *= -1;
    }
    if (trajectory_pos.y > height-bottom_border || trajectory_pos.y < top_border) {
      if (trajectory_pos.y > height-bottom_border) {
        trajectory_pos.y = height-bottom_border;
      } else {
        trajectory_pos.y = top_border;
      }
      trajectory_vel.y *= -1;
    }

    //take_care_of_wall_bounce(trajectory_pos, trajectory_vel);


    noStroke();



    fill(0, 255, 0);
    circle(trajectory_pos.x, trajectory_pos.y, 2);

    trajectory[i] = trajectory_pos;
  }

  Planet soi = planets.get(soi_planet);


  //test if trajectory gets stuck
  boolean going_to_die = false;
  
  float sum = 0;
  for(int v = trajectory_lookahead - 500; v < trajectory_lookahead; v++){
    sum += sq(PVector.sub(trajectory[v], soi.pos).mag());
  }

  if (sum/500 < soi.radius){
    going_to_die = true;
  }
  

  //draw ship
  if (going_to_die) {
    fill(ship.col);
  } else {
    fill(color(0, 255, 255));
  }
  circle(ship.pos.x, ship.pos.y, ship.radius);

  //draw all planets
  for (Planet p : planets) {
    noStroke();
    fill(p.col);
    circle(p.pos.x, p.pos.y, p.radius);
  }

  //color the current soi planet, mainly for debug atm
  fill(0, 255, 0);
  noStroke();
  circle(soi.pos.x, soi.pos.y, soi.radius);
}

void mousePressed() {
  loop();
}
