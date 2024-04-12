final int screen_width = 1280;
final int screen_height = 720;
final float ball_diameter = 720/25;
final float ball_mass = ball_diameter*.1;

Ball cue_ball;
ArrayList<Ball> balls = new ArrayList<>();
PoolTable table;
int frame = 0;


void settings() {
    size(screen_width, screen_height);
}


void setup() {
    frameRate(60);
    table = new PoolTable(7, 300, new PVector(screen_width/2,screen_height/2));
    cue_ball = new Ball(screen_width/2,screen_height/2 + 100, ball_diameter, ball_mass+0.5, "white");
    cue_ball.applyForce(new PVector(0, -200));
    balls.add(cue_ball);
    
    balls.add(new Ball(screen_width/2,screen_height/2 - 175, ball_diameter, ball_mass, "red"));
    balls.add(new Ball(screen_width/2,screen_height/2 - 100, ball_diameter, ball_mass, "blue"));
}


void draw() {
  frame += 1;
  if (frame % 1 == 0) {
    render();
    updateMovements();
  }
}


void render() {
  background(255);
  table.draw();
  for (Ball b : balls) {
    b.draw();
  }
  //noLoop();
}


void updateMovements() {
  for (Ball b : balls) {
    b.applyDrag();
  }
  for (Ball b : balls) {
    b.move();
  }
  // for (Ball b : balls) {
  //  table.boundaryCollision(b);
  // }
  // check all pairs of balls for collision
  for (int i = 0; i < balls.size()-1; i++){
    for (int j = i + 1; j < balls.size(); j++){
      balls.get(i).ballCollision(balls.get(j));
    }
  }
  for (Ball b : balls) {
    // Slight logical error here - since ball velocity can be changed by a collision, the method of going back using velocity isnt quite correct. only fix this if there is an actual error with balls phasing out of table in the game
   table.boundaryCollision(b);
  }
}

void mousePressed() {
  loop();
  //balls.add(new Ball(mouseX, mouseY, 20, 2, "white"));
}
