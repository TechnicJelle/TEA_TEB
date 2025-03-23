class Scene_MainMenu implements Scene {
  void init() {
  }

  void step() {
    background(0);
    textAlign(CENTER, CENTER);

    PVector shipos = new PVector(width*1/5, height*1/2);
    pushMatrix();
    translate(shipos.x, shipos.y);
    scale(1);
    stroke(200, 10, 10);
    strokeWeight(200);
    beginShape(LINES);
      //vertex(width*1/5, height*1/2);
      vertex(0, 0);
      vertex(width, width);
    endShape();
    popMatrix();

    Ship ship = new Ship(shipos, new PVector(-1, -1), 30);
    ship.draw();

    fill(GREEN);

    textFont(fntOrbitronBlack);
    textSize(128);
    text("Geodesic", width*0.440, height*0.2);

    textFont(fntOrbitronBold);
    textSize(64);
    text("By Team Geodesic", width*0.556, height*0.3);

    textFont(fntOrbitronRegular);
    textSize(32);
    text("Press space or click to start...", width/2f, height*0.9);

    text("Traverse large stretches of space.\nThe bigger the passage, the better.", width*2/3f, height*1/2f);


    textAlign(RIGHT, BOTTOM);
    textSize(20);
    text("Made with Processing", width-10, height-20);
  }

  void mousePressed() {
  }

  void mouseDragged() {
  }

  void mouseReleased() {
    gameState.nextScene();
  }

  void mouseWheel(MouseEvent event) {
  }

  void keyPressed() {
  }

  void keyReleased() {
    gameState.nextScene();
  }

  void cleanup() {
  }
}
