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

PVector last_score_pos;
int score;

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
final float cost_per_adjustment = 2.2; //how much fuel one adjustment costs
final float reward_per_lock_in = 1.1;

int lock_in_amount;

MoveChoiceCard[] moveChoiceCards = new MoveChoiceCard[3];

final int maxPlanetExplosions = 5;
int amountOfExplodedPlanets;

class Scene_InGame implements Scene {
  float screwAngleLB;
  float screwAngleLT;
  float screwAngleRB;
  float screwAngleRT;

  int sceneStartMillis;

  float y_padding = 10;
  float left = left_border/2;
  float bottom = height - y_padding;
  float right = width - right_border/2;
  float top = height - bottom_border + y_padding;
  float content_height = bottom - top - y_padding*2;
  float cardWidth = content_height/3f*2f;
  float visualCenter = width*0.425;

  void init() {
    ship = new Ship(new PVector(19 * width / 20, height / 2), new PVector(-5, 0), 15, color(200, 200, 200));
    last_score_pos = ship.pos;
    score = 0;

    _voronoiCalculationStage = VoronoiCalculationStage.FIRST_BACKGROUND;
    moveType = MoveType.FLYING;
    flying_paused = true;

    screwAngleLB = random(0, TWO_PI);
    screwAngleLT = random(0, TWO_PI);
    screwAngleRB = random(0, TWO_PI);
    screwAngleRT = random(0, TWO_PI);

    adjustment_count = 0;
    lock_in_amount = 0;

    amountOfExplodedPlanets= 0;

    moveChoiceCards[0] = new SteerChoiceCard(visualCenter-cardWidth*2, top + y_padding, cardWidth, content_height);
    moveChoiceCards[1] = new ExplodePlanetChoiceCard(visualCenter-cardWidth/2, top + y_padding, cardWidth, content_height);
    moveChoiceCards[2] = new LockInChoiceCard(visualCenter+cardWidth, top + y_padding, cardWidth, content_height);

    score = 0;
  }

  void step() {
    switch(_voronoiCalculationStage) {
    case FIRST_BACKGROUND:
      background(0);
      textAlign(CENTER, CENTER);
      textFont(fntOrbitronRegular);
      fill(GREEN);

      textSize(64);
      text("Calculating Trajectories...", width/2f, height/2f);
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
            if (lock_in_amount <= 0) flying_paused = true;
            else {
              lock_in_amount -= 1;
              ship.fuel += reward_per_lock_in;
              ship.fuel = max(ship.fuel, 0.0);
              ship.fuel = min(ship.fuel, 100.0);
            }
            score += sq(PVector.dist(ship.pos, last_score_pos));
            last_score_pos = ship.pos.copy();
            last_soi_planet = soi_planet;
            break;
          }
        } /* ship simulation step for-loop */

        actual_trajectory_calculation();
      } /* flying paused if-statement */

      image(grBkgrVoronoi, 0, 0);

      noStroke();
      fill(200, 30, 190);
      int last_soi = trajectory_sois[0];
      int local_lock_in_amount = lock_in_amount;
      for (int i = 0; i < trajectory_lookahead; i++) {
        if (local_lock_in_amount < 0) {
          fill(0, 255, 0);
        } else if (trajectory_sois[i] != last_soi) local_lock_in_amount -= 1;
        circle(trajectory[i].x, trajectory[i].y, 2);
        last_soi = trajectory_sois[i];
      }

      ship.draw();

      //draw all planets
      for (Planet p : planets) {
        //noStroke();
        stroke(p.col);
        strokeWeight(p.radius);
        point(p.pos.x, p.pos.y);
        //pushMatrix();
        //translate(p.pos.x, p.pos.y);
        //randomSeed(p.seed);
        //rotate(random(0, 100));
        //scale(p.radius);

        //stroke(p.col);
        //strokeWeight(1/p.radius);
        ////circle(0, 0, 1);
        //beginShape(LINES);
        //  vertex(0, -1);
        //  vertex(0, 1);

        //  vertex(-0.8, -0.25);
        //  vertex(0.8, 0.25);

        //  vertex(-0.8, 0.25);
        //  vertex(0.8, -0.25);

        //  vertex(-0.2, -0.2);
        //  vertex(0.2, 0.2);
        //  vertex(-0.2, 0.2);
        //  vertex(0.2, -0.2);
        //endShape();

        //strokeWeight(2/p.radius);
        //beginShape(LINES);
        //  vertex(0, -0.9);
        //  vertex(0, 0.9);

        //  vertex(-0.7, -0.15);
        //  vertex(0.7, 0.15);

        //  vertex(-0.7, 0.15);
        //  vertex(0.7, -0.15);
        //endShape();

        //popMatrix();
      }
      if (flying_paused && moveType == MoveType.EXPLODE_PLANET) {
        Planet p = planets.get(closest_soi(new PVector(mouseX, mouseY)));
        stroke(255, 0, 0);
        strokeWeight(p.radius);
        point(p.pos.x, p.pos.y);
      }

      //println(score/width);

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
      text("Re-Calculating Trajectories...", width/2f, height/2f);
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
    rect(left, bottom, right, top, 28);
    float screw_offset = 24;
    drawScrew(left + screw_offset, bottom - screw_offset, screwAngleLB);
    drawScrew(left + screw_offset, top + screw_offset, screwAngleLT);
    drawScrew(right - screw_offset, bottom - screw_offset, screwAngleRB);
    drawScrew(right - screw_offset, top + screw_offset, screwAngleRT);

    //content
    pushMatrix(); // left panel content -->
    float content_x_padding = 48;
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

    translate(content_height + content_x_padding, 0);
    switch(moveType) {
    case FLYING:
      break;
    case STEER:
      pushMatrix(); //steering indicator -->
      translate(content_height, content_height);
      fill(180);
      noStroke();
      arc(0, 0, content_height*2.1, content_height*2.1, PI, TWO_PI);
      fill(150);
      float fuelLeft = map(ship.fuel, 100, 0, 0, HALF_PI);
      arc(0, 0, content_height*2, content_height*2, PI + fuelLeft, TWO_PI - fuelLeft);

      textAlign(CENTER, CENTER);
      textFont(fntOrbitronBold);
      textSize(32);
      fill(50);
      text("Direction", 0, content_height * -0.75);

      rotate(map(adjustment_count, -100.0f/cost_per_adjustment, 100.0f/cost_per_adjustment, HALF_PI, -HALF_PI));
      fill(RED);
      triangle(
        0, -content_height*0.9, //center
        -10, 0, //bottom left
        10, 0 //bottom right
        );
      popMatrix(); // <-- steering indicator

      textAlign(LEFT, CENTER);
      textFont(fntOrbitronBold);
      textSize(24);
      fill(50);
      text("Arrow Keys to adjust course.\nPress SPACE to continue the flight!", content_x_padding + content_height*2, content_height*0.5);
      break;
    case EXPLODE_PLANET:
      textAlign(CENTER, CENTER);
      textFont(fntOrbitronBold);
      textSize(32);
      fill(50);
      text("Exploded planets:\n" + amountOfExplodedPlanets + "/" + maxPlanetExplosions, content_height, content_height*0.5);

      textAlign(LEFT, CENTER);
      textFont(fntOrbitronBold);
      textSize(32);
      fill(50);
      text("Click on a planet to explode it.\nPress SPACE to continue the flight!", content_x_padding + content_height*2, content_height*0.5);
      break;
    case LOCK_IN:
      float lockinWidth = content_height/3*2;
      pushMatrix(); //lock-in steps amount -->
      stroke(120);
      strokeWeight(5);
      fill(180);
      rect(0, 0, lockinWidth, content_height);

      textAlign(CENTER, CENTER);
      textFont(fntOrbitronBold);
      textSize(64);
      fill(50);
      text(lock_in_amount, lockinWidth/2, content_height * 0.5);

      stroke(50);
      strokeWeight(10);
      //top
      line(lockinWidth/2-35, 40, lockinWidth/2, 10);
      line(lockinWidth/2+35, 40, lockinWidth/2, 10);
      //bottom
      line(lockinWidth/2-35, content_height-40, lockinWidth/2, content_height-10);
      line(lockinWidth/2+35, content_height-40, lockinWidth/2, content_height-10);

      textAlign(LEFT, CENTER);
      textFont(fntOrbitronBold);
      textSize(32);
      fill(50);
      text("Scroll to increase the Lock-In Steps.\nPress SPACE to continue the flight!", lockinWidth + content_x_padding, content_height * 0.5);

      popMatrix(); // <-- lock-in steps amount
      break;
    }

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

    translate(-batteryWidth, 0);

    if (moveType == MoveType.STEER) {
      pushMatrix();
      translate(-content_height * 0.90 - content_x_padding, 0);
      drawDeepRect(content_height, content_height);
      popMatrix();
      fill(0);
      textFont(fntOrbitronRegular);
      textAlign(RIGHT, CENTER);
      textSize(24);
      text("Next move\nwill cost:", -batteryWidth*0.75, content_height*0.35);
      textSize(38);
      text(round(abs(adjustment_count * cost_per_adjustment)) + "%", -batteryWidth*0.75, content_height*0.65);
    }

    popMatrix(); // <-- right panel content

    if (flying_paused) {
      if (moveType == MoveType.FLYING) {
        for (MoveChoiceCard card : moveChoiceCards) {
          card.step();
        }
      }
    } else {
      textAlign(CENTER, CENTER);
      textFont(fntOrbitronBold);
      textSize(32);
      fill(50);
      text("Ship is in flight...\nPlease hold on...", visualCenter, top + y_padding + content_height*0.5);
      if (lock_in_amount != 0) {
        text("Steps left: " + lock_in_amount, visualCenter + content_height*2.2, top + y_padding + content_height*0.5);
      }
    }
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

    if (flying_paused) {
      if (moveType == MoveType.EXPLODE_PLANET) {
        amountOfExplodedPlanets++;
        planets.remove(closest_soi(new PVector(mouseX, mouseY)));
        recalc_voronoi();
        actual_trajectory_calculation();
        if (amountOfExplodedPlanets >= maxPlanetExplosions) {
          continueFlying();
        }
      } else if (moveType == MoveType.FLYING) {
        for (MoveChoiceCard card : moveChoiceCards) {
          card.checkClick();
        }
      }
    }
  }

  void mouseWheel(MouseEvent event) {
    if (flying_paused && moveType == MoveType.LOCK_IN) {
      float e = event.getCount();
      lock_in_amount = constrain(lock_in_amount - round(e), 0, 10);
    }
  }

  void keyPressed() {
    PVector velocity_increment = new PVector(ship.vel.y, -ship.vel.x);
    velocity_increment.normalize().mult(0.001);
    switch(keyCode) {
    case LEFT:
      if (flying_paused && moveType == MoveType.STEER) {
        if (ship.fuel <= 0 || (abs(adjustment_count)+1)*cost_per_adjustment > ship.fuel) {
          if (adjustment_count < 0) adjustment_count += 1;
          break;
        }
        adjustment_count += 1;
        ship.vel.add(velocity_increment);
        actual_trajectory_calculation();
      }
      break;

    case RIGHT:
      if (flying_paused && moveType == MoveType.STEER) {
        if (ship.fuel <= 0 || (abs(adjustment_count)+1)*cost_per_adjustment > ship.fuel) {
          if (adjustment_count > 0) adjustment_count -= 1;
          break;
        }
        adjustment_count -= 1;
        ship.vel.sub(velocity_increment);
        actual_trajectory_calculation();
      }
      break;
    }
  }

  void continueFlying() {
    if (moveType != MoveType.FLYING) {
      amountOfExplodedPlanets = 0;
      moveType = MoveType.FLYING;
      flying_paused = false;
      ship.fuel -= abs(adjustment_count)*cost_per_adjustment;
      ship.fuel = max(ship.fuel, 0.0);
      ship.fuel = min(ship.fuel, 100.0);
      adjustment_count = 0;
    }
  }

  void keyReleased() {
    switch(key) {
    case ' ':
    case ENTER:
    case RETURN:
      continueFlying();
      break;
    }
  }

  void cleanup() {
  }
}
