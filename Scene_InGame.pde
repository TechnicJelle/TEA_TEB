ArrayList<Planet> planets;

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
boolean going_to_die;

float ship_exclusion_radius = 100;

int frameCounter = 0;

class Scene_InGame implements Scene {
  void init() {
    ship = new Ship(new PVector(19 * width / 20, height / 2), new PVector(-5, 0), 15, color(0, 255, 255));

    frameCounter = 0;
  }

  void step() {
    if (frameCounter == 0) {
      background(0);
      textAlign(CENTER, CENTER);
      textFont(fntOrbitron);
      fill(GREEN);

      textSize(64);
      text("Calculating Trajectory...", width/2f, height/2f);
    } else if (frameCounter == 1) {
      generate_all_planets_with_constraints();
      draw_voronoi_to_background();
    } else {
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
      int[] trajectory_sois = new int[trajectory_lookahead];

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
        trajectory_sois[i] = soi_planet;
      }

      Planet soi = planets.get(soi_planet);


      going_to_die = true;
      //test if trajectory gets stuck
      for (int v = trajectory_lookahead - trajectory_lookahead/3; v < trajectory_lookahead; v++) {
        if (trajectory_sois[v] != trajectory_sois[v-1]) {
          going_to_die = false; 
        }
      }

      //draw ship
      if (going_to_die) {
        fill(color(255, 100, 100));
      } else {
        fill(ship.col);
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
    frameCounter++;
  }

  void mousePressed() {
    loop();
  }

  void mouseDragged() {
  }

  void mouseReleased() {
  }

  void keyPressed() {
  }

  void keyReleased() {
  }

  void cleanup() {
  }
}
