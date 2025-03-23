class Planet {
  PVector pos;

  float mass;
  float radius;
  color col;

  Planet(PVector p, float m, float r, color c) {
    pos = p;
    mass = m;
    radius = r;
    col = c;
  }
}

void generate_all_planets_with_constraints() {
  ArrayList<Planet> initial_planets = new ArrayList<Planet>();
  planets = new ArrayList<Planet>();

  for (int i = 0; i < 250; i++) {
    Planet plant = new Planet(new PVector(random(width), random(height)), random(1, 200), random(2, 20), color(255));
    plant.radius = 2;
    plant.radius += 20*(plant.mass-1)/200;
    initial_planets.add(plant);
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
}

int closest_soi(PVector pos) {
  float largest_grav_force = 0.0;
  int closest = 0;
  for (int soi = 0; soi < planets.size(); soi++) {
    Planet p = planets.get(soi);
  
    PVector difference = PVector.sub(pos, p.pos);
    float sq_distance = sq(difference.mag());
    float gravitational_force = G * p.mass / sq_distance;
  
    //if bigger, set new soi
    if (gravitational_force > largest_grav_force) {
      largest_grav_force = gravitational_force;
      closest = soi;
    }
  }
  return closest;
}
