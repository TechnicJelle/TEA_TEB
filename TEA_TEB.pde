import processing.sound.*;

ArrayList<Planet> planets;

PGraphics grBkgrVoronoi;

PVector ship_pos;
PVector ship_vel = new PVector(-5, 0);
PVector ship_acc = new PVector(0, 0);

float ship_rad = 15;
float dt = 0.05;
float G = 5;

int soi_planet = 0;
int last_soi_planet = 0;

void setup() {
  fullScreen();
  ship_pos = new PVector(19 * width / 20, height / 2);

  ArrayList<Planet> initial_planets = new ArrayList<Planet>();
  planets = new ArrayList<Planet>();


  for (int i = 0; i < 250; i++) {
    initial_planets.add(new Planet(new PVector(random(width), random(height)), random(1, 200), random(2, 20), color(255)));
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

      float dist_to_line; {
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
    ship_acc = new PVector(0, 0);
    float largest_grav_force = 0;

    for (int j = 0; j < planets.size(); j++) {
      Planet p = planets.get(j);
      
      PVector difference = PVector.sub(ship_pos, p.pos);
      float sq_distance = sq(difference.mag());   
      float gravitational_force = G * p.mass / sq_distance;
      
      //if bigger, set new soi
      if(gravitational_force > largest_grav_force){
        largest_grav_force = gravitational_force;
        soi_planet = j;
      }     
    }
    
    if (soi_planet != last_soi_planet){
      noLoop();
      last_soi_planet = soi_planet;
      break;
    }
    
    
    //do the soi stuff
    Planet soi = planets.get(soi_planet);
    PVector difference = PVector.sub(ship_pos, soi.pos);
    float sq_distance = 1 + sq(difference.mag());
    ship_acc.add(difference.normalize().mult(-G * soi.mass / sq_distance));

    ship_vel.add(PVector.mult(ship_acc, dt));
    ship_pos.add(PVector.mult(ship_vel, dt));
    
    //support wrap-around
    ship_pos.x = ship_pos.x % width;
    ship_pos.y = ship_pos.y % height;
    
  }

  //draw ship
  fill(color(200));
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
