ArrayList<Planet> planets;

Ship ship;

float dt = 0.05;
float G = 5;
float velocity_limit = 25;

//int soi_planet = 0;
int last_soi_planet = 0;

int left_border = 50;
int right_border = 50;
int top_border = 50;
int bottom_border = 200;

int trajectory_lookahead = 2500;
PVector[] trajectory = new PVector[trajectory_lookahead];
int[] trajectory_sois = new int[trajectory_lookahead];

boolean going_to_die;

float ship_exclusion_radius = 100;

boolean flying_paused = false;
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
      if (!flying_paused) { /* flying paused if-statement */
        //int soi_planet = last_soi_planet;
        for (int i = 0; i < 10; i++) {/* ship simulation step for-loop */
          int soi_planet = continuation_in_space(ship.pos, ship.vel, ship.acc);
          if (soi_planet != last_soi_planet) {
            flying_paused = true;
            last_soi_planet = soi_planet;
            break;
          }
        } /* ship simulation step for-loop */

        actual_trajectory_calculation();
      } /* flying paused if-statement */

      image(grBkgrVoronoi, 0, 0);

      for (int i = 0; i < trajectory_lookahead; i++) {
        noStroke();
        fill(0, 255, 0);
        circle(trajectory[i].x, trajectory[i].y, 2);
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
      //  fill(0, 255, 0);
      //    noStroke();
      //      circle(soi.pos.x, soi.pos.y, soi.radius);
    }
    frameCounter++;
  }

  void mousePressed() {
    flying_paused = false;
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
