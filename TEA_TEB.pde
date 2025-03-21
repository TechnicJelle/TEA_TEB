import processing.sound.*;


ArrayList<Planet> planets;

PGraphics grBkgrVoronoi;

void setup() {
  fullScreen();

  ArrayList<Planet> initial_planets = new ArrayList<Planet>();
  planets = new ArrayList<Planet>();


  for (int i = 0; i < 250; i++) {
    initial_planets.add(new Planet(new PVector(random(width), random(height)), random(0, 100), random(2, 20), color(255)));
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
      float closest_2 = Float.MAX_VALUE - 1;

      for (Planet p : planets) {
        float distance = dist(x, y, p.pos.x, p.pos.y);

        if (distance < closest_2) {
          closest_2 = distance;
        }

        if (closest_2 < closest_1) {
          float temp = closest_2;
          closest_2 = closest_1;
          closest_1 = temp;
        }
      }

      if (closest_2 - closest_1 < 50 * (closest_2 - closest_1) / (closest_1 + closest_2)) {
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
}

void mousePressed() {
}
