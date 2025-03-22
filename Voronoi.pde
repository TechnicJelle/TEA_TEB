PGraphics grBkgrVoronoi;

void draw_voronoi_to_background() {
  grBkgrVoronoi = createGraphics(width, height);
  grBkgrVoronoi.beginDraw();
  grBkgrVoronoi.background(0);

  grBkgrVoronoi.loadPixels();
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
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
      if (dist_to_line < 0.03) {
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
}
