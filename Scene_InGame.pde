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

int adjustment_count = 0;
float cost_per_adjustment = 2;

class Scene_InGame implements Scene {
  float screwAngleLB;
  float screwAngleLT;
  float screwAngleRB;
  float screwAngleRT;

  void init() {
    ship = new Ship(new PVector(19 * width / 20, height / 2), new PVector(-5, 0), 15, color(0, 255, 255));

    frameCounter = 0;

    screwAngleLB = random(0, TWO_PI);
    screwAngleLT = random(0, TWO_PI);
    screwAngleRB = random(0, TWO_PI);
    screwAngleRT = random(0, TWO_PI);
  }

  void step() {
    if (frameCounter == 0) {
      background(0);
      textAlign(CENTER, CENTER);
      textFont(fntOrbitronRegular);
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

      drawUI();
    }
    frameCounter++;
  }

  void drawUI() {
    //panel
    fill(200);
    noStroke();
    rectMode(CORNERS);
    float y_padding = 10;
    float left = left_border/2;
    float bottom = height - y_padding;
    float right = width - right_border/2;
    float top = height - bottom_border + y_padding;
    rect(left, bottom, right, top, 28);
    float screw_offset = 24;
    drawScrew(left + screw_offset, bottom - screw_offset, screwAngleLB);
    drawScrew(left + screw_offset, top + screw_offset, screwAngleLT);
    drawScrew(right - screw_offset, bottom - screw_offset, screwAngleRB);
    drawScrew(right - screw_offset, top + screw_offset, screwAngleRT);
  }

  void drawScrew(float x, float y, float angle) {
    noStroke();
    fill(64);
    pushMatrix();
    translate(x, y);
    float diam = 32;
    circle(0, 0, diam);
    rotate(angle);
    strokeWeight(3);
    stroke(20);
    diam *= 0.3;
    line(-diam, 0, diam, 0);
    line(0, -diam, 0, diam);
    popMatrix();
  }

  void mousePressed() {
  }

  void mouseDragged() {
  }

  void mouseReleased() {
  }

  void keyPressed() {
    PVector velocity_increment = new PVector(ship.vel.y, -ship.vel.x);
    velocity_increment.normalize().mult(0.001);
    if (key == CODED) {
      switch(keyCode) {
      case LEFT:
        if (flying_paused == true) {
          if (ship.fuel <= 0 || abs(adjustment_count)*cost_per_adjustment > ship.fuel) {
              if (adjustment_count < 0) adjustment_count += 1;
              break;
          }
          adjustment_count += 1;
          ship.vel.add(velocity_increment);
          actual_trajectory_calculation();
        }
        break;

      case RIGHT:
        if (flying_paused == true) {
          if (ship.fuel <= 0 || abs(adjustment_count)*cost_per_adjustment > ship.fuel) {
              if (adjustment_count > 0) adjustment_count -= 1;
              break;
          }
          adjustment_count -= 1;
          ship.vel.sub(velocity_increment);
          actual_trajectory_calculation();
        }
        break;
      }
    } else {
      switch(key) {
      case ' ':
        flying_paused = false;
        ship.fuel -= abs(adjustment_count)*cost_per_adjustment;
        ship.fuel = max(ship.fuel, 0.0);
        ship.fuel = min(ship.fuel, 100.0);
        adjustment_count = 0;
        break;
      }
    }
    println(ship.fuel, adjustment_count);

  }

  void keyReleased() {
  }

  void cleanup() {
  }
}
