ArrayList<Planet> planets;

Ship ship;

final float dt = 0.05;
final float G = 5;
final float velocity_limit = 25;

final int left_border = 5;
final int right_border = 5;
final int top_border = 5;
final int bottom_border = 200;

final int trajectory_lookahead = 2500;
PVector[] trajectory = new PVector[trajectory_lookahead];
int[] trajectory_sois = new int[trajectory_lookahead];

boolean going_to_die;

final float ship_exclusion_radius = 100;

boolean flying_paused;
VoronoiCalculationStage _voronoiCalculationStage;
enum VoronoiCalculationStage {
  FIRST_BACKGROUND, CALCULATING, IN_GAME, RE_BACKGROUND, RE_CALCULATING
}

void recalc_voronoi() {
  if (_voronoiCalculationStage == VoronoiCalculationStage.IN_GAME) {
    _voronoiCalculationStage = VoronoiCalculationStage.RE_BACKGROUND;
  }
}

boolean pointOverSelfExplodeButton(float x, float y) {
  return x > width * 0.792 && x < width * 0.976 && y > height * 0.785 && y < height * 1.000;
}

int adjustment_count; //how much steering adjustment has been made for the next move
final float cost_per_adjustment = 2; //how much fuel one adjustment costs

int premove_amount;

class Scene_InGame implements Scene {
  float screwAngleLB;
  float screwAngleLT;
  float screwAngleRB;
  float screwAngleRT;

  int sceneStartMillis;

  void init() {
    ship = new Ship(new PVector(19 * width / 20, height / 2), new PVector(-5, 0), 15, color(0, 255, 255));

    _voronoiCalculationStage = VoronoiCalculationStage.FIRST_BACKGROUND;
    flying_paused = true;

    screwAngleLB = random(0, TWO_PI);
    screwAngleLT = random(0, TWO_PI);
    screwAngleRB = random(0, TWO_PI);
    screwAngleRT = random(0, TWO_PI);
    
    adjustment_count = 0;
    premove_amount = 0;
  }

  void step() {
    switch(_voronoiCalculationStage) {
    case FIRST_BACKGROUND:
      background(0);
      textAlign(CENTER, CENTER);
      textFont(fntOrbitronRegular);
      fill(GREEN);

      textSize(64);
      text("Calculating Trajectory...", width/2f, height/2f);
      _voronoiCalculationStage = VoronoiCalculationStage.CALCULATING;
      break;
    case CALCULATING:
      //no need for any drawing; the stuff from last frame is still on screen
      generate_all_planets_with_constraints();
      draw_voronoi_to_background();
      actual_trajectory_calculation();
      sceneStartMillis = millis();
      _voronoiCalculationStage = VoronoiCalculationStage.IN_GAME;
      break;
    case IN_GAME:
      if (!flying_paused) { /* flying paused if-statement */
        int last_soi_planet = closest_soi(ship.pos);
        for (int i = 0; i < 10; i++) {/* ship simulation step for-loop */
          int soi_planet = continuation_in_space(ship.pos, ship.vel, ship.acc);
          if (soi_planet != last_soi_planet) {
            if (premove_amount <= 0) flying_paused = true;
            else premove_amount -= 1;
            last_soi_planet = soi_planet;
            break;
          }
        } /* ship simulation step for-loop */

        actual_trajectory_calculation();
      } /* flying paused if-statement */

      image(grBkgrVoronoi, 0, 0);

      noStroke();
      fill(30, 255, 255);
      int last_soi = trajectory_sois[0];
      int local_premove_amount = premove_amount;
      for (int i = 0; i < trajectory_lookahead; i++) {
        if (local_premove_amount < 0) {
          fill(0, 255, 0);
        } else if (trajectory_sois[i] != last_soi) local_premove_amount -= 1;
        circle(trajectory[i].x, trajectory[i].y, 2);
        last_soi = trajectory_sois[i];
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
      break;
    case RE_BACKGROUND:
      tint(100);
      image(grBkgrVoronoi, 0, 0);
      noTint();
      textAlign(CENTER, CENTER);
      textFont(fntOrbitronRegular);
      fill(GREEN);

      textSize(64);
      text("Re-Calculating Trajectory...", width/2f, height/2f);
      _voronoiCalculationStage = VoronoiCalculationStage.RE_CALCULATING;
      break;
    case RE_CALCULATING:
      image(grBkgrVoronoi, 0, 0);
      draw_voronoi_to_background();
      _voronoiCalculationStage = VoronoiCalculationStage.IN_GAME;
      break;
    }
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

    //content
    pushMatrix(); // left panel content -->
    float content_x_padding = 48;
    float content_height = bottom - top - y_padding*2;
    translate(left + content_x_padding, top + y_padding);

    //Indicator: Going To Die?
    drawDeepRect(content_height, content_height);

    pushMatrix(); // warning icon -->
    translate(content_height*0.50, content_height*0.40);
    scale(0.35);

    if (going_to_die) {
      fill(247, 198, 75);
      stroke(0);
      strokeWeight(5);
      strokeJoin(ROUND);
    } else {
      fill(50);
    }
    triangle(
      0, -content_height/2, //top
      -content_height/2, content_height/2, //bottom left
      content_height/2, content_height/2 //bottom right
      );

    if (going_to_die) {
      textAlign(CENTER, CENTER);
      textSize(120);
      fill(50);
      text("!", -2, 12);
    }

    popMatrix(); // <-- warning icon
    strokeJoin(MITER);

    if (going_to_die) {
      fill(GREEN);
    } else {
      fill(100);
    }
    textFont(fntOrbitronBold);
    textSize(24);
    textAlign(CENTER, TOP);
    text("WARNING:", content_height/2, 10);
    textFont(fntOrbitronBlack);
    textSize(16);
    textAlign(CENTER, BOTTOM);
    text("Potential\nCollision\nImminent!", content_height/2, content_height - 3);

    popMatrix(); // <-- left panel content

    //-----------------------------------

    pushMatrix(); // right panel content -->
    translate(right - content_x_padding, top + y_padding);

    //Button: Restart

    boolean buttonHovered = pointOverSelfExplodeButton(mouseX, mouseY);
    if (buttonHovered) {
      stroke(150);
      strokeWeight(4);
      fill(200, 100);

      quad(
        content_height * -2.10, content_height * -0.30, //top left
        content_height * 0.05, content_height * -0.30, //top right
        content_height * -0.10, content_height * 0.60, //bottom right
        -content_height * 1.90, content_height * 0.60); //bottom left
    }

    //button base
    noStroke();
    fill(100);
    rect(0, content_height / 2, -content_height * 2, content_height / 2, 5);
    //bottom round shade
    fill(200, 0, 0);
    ellipse(-content_height, content_height * 0.67, -content_height * 1.7, content_height * 0.50);
    if (mousePressed && buttonHovered) {
      rectMode(CENTER);
      rect(-content_height, content_height * 0.58, -content_height * 1.7, content_height * 0.20);
      rectMode(CORNER);
      fill(255, 0, 0);
      ellipse(-content_height, content_height * 0.48, -content_height * 1.7, content_height * 0.50);
    } else {
      rectMode(CENTER);
      rect(-content_height, content_height * 0.46, -content_height * 1.7, content_height * 0.38);
      rectMode(CORNER);
      fill(255, 0, 0);
      ellipse(-content_height, content_height * 0.25, -content_height * 1.7, content_height * 0.50);
    }
    if (!buttonHovered) {
      stroke(150);
      strokeWeight(4);
      fill(200, 100);
      rect(content_height * -0.05, -content_height * 0.03, -content_height * 1.90, content_height * 0.64, 5, 5, 0, 0);

      noStroke();
      rect(content_height * -0.05, -content_height * -0.62, -content_height * 1.90, content_height * 0.25);

      stroke(150);
      strokeWeight(4);
      line(-content_height * 1.950, -content_height * -0.60, -content_height * 1.95, -content_height * -0.87); //left
      line(content_height * -0.05, -content_height * -0.60, content_height * -0.05, -content_height * -0.87); //right
    }


    //Indicator: Fuel
    translate(-content_height*2 - content_x_padding, 0);
    float batteryWidth = content_height/3;

    fill(0);
    textFont(fntOrbitronBold);
    textSize(24);
    textAlign(CENTER, TOP);
    text("FUEL:", -batteryWidth/2, -7);

    textFont(fntOrbitronRegular);
    textSize(24);
    textAlign(CENTER, BOTTOM);
    text(round(ship.fuel) + "%", -batteryWidth/2, content_height+12);

    noStroke();
    fill(lerpColor(RED, GREEN, ship.fuel/100.0f));
    rect(0, content_height - 20, -batteryWidth, (-content_height + 40) / 100.0f * ship.fuel);

    stroke(0);
    strokeWeight(3);
    noFill();
    rect(0, 20, -batteryWidth, content_height - 40);

    popMatrix(); // <-- right panel content
  }

  void drawDeepRect(float rWidth, float rHeight) {
    float depth = 5;
    noStroke();
    rectMode(CORNER);
    fill(100);
    rect(0, 0, rWidth, rHeight);
    fill(128);
    rect(depth, depth, rWidth-depth, rHeight-depth);
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
    if (_voronoiCalculationStage != VoronoiCalculationStage.IN_GAME) return;
    if (millis() - sceneStartMillis < 100) return;
    if (pointOverSelfExplodeButton(mouseX, mouseY)) {
      gameState.nextScene();
    }
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
      case 'v':
        for (int removal = 0; removal < 25; removal += 1) {
          if (planets.size() > 5) planets.remove(0);
        }
        recalc_voronoi();
        actual_trajectory_calculation();
        break;
      case 'p':
        premove_amount = 10;
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
