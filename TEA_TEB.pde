import processing.sound.*;

ArrayList<Planet> planets;

PGraphics grBkgrVoronoi;

PVector ship_pos;
PVector ship_vel = new PVector(-50, 0);
PVector ship_acc = new PVector(0, 0);

float ship_rad = 10;
float dt = 0.2;

void setup() {
  fullScreen();
  ship_pos = new PVector(19 * width / 20, height / 2);

  ArrayList<Planet> initial_planets = new ArrayList<Planet>();
  planets = new ArrayList<Planet>();


  for (int i = 0; i < 250; i++) {
    initial_planets.add(new Planet(new PVector(random(width), random(height)), random(10, 20), random(2, 20), color(255)));
  }

  for (int i = 0; i < initial_planets.size(); i++) {
    Planet p = initial_planets.get(i);
    boolean touching = false;
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
        float distance = dist(x, y, p.pos.x, p.pos.y);

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

      float dist_to_line; {
        PVector line_between_planets = PVector.sub(closest_vec_2, closest_vec_1);
        PVector point_between_planets = PVector.add(closest_vec_1, PVector.div(line_between_planets, 2));
        PVector point = new PVector((float)x, (float)y);
        PVector rpoint = PVector.sub(point_between_planets, point);
        dist_to_line = PVector.dot(rpoint, line_between_planets)/line_between_planets.mag();
      }
      if (dist_to_line < 2) {
       //make line
        grBkgrVoronoi.pixels[x + y * width] = color(0);
      } else {
        //make gradient
        grBkgrVoronoi.pixels[x + y * width] = color(255 / (1 + closest_1/100), 10, 50);
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
  for (int i = 0; i < 250; i++) {
    ship_acc = new PVector(0, 0);

    boolean touching = false;
    for (Planet p : planets) {
      PVector difference = PVector.sub(ship_pos, p.pos);
      float sq_distance = sq(difference.mag());
      ship_acc.add(difference.normalize().mult(-p.mass / sq_distance));

      if (sq_distance < sq(p.radius + ship_rad)) {
        touching = true;
      }
    }

    ship_vel.add(ship_acc.mult(dt));

    //shitty collisions
    if (touching) {ship_vel.mult(-1);}
  }

  //draw ship
  ship_pos.add(ship_vel.mult(dt));
  fill(color(0, 0, 255));
  circle(ship_pos.x, ship_pos.y, ship_rad);


  //draw planets
  for (Planet p : planets) {
    noStroke();
    fill(p.col);
    circle(p.pos.x, p.pos.y, p.radius);
  }
}

void mousePressed() {
}
