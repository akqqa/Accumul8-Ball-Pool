final int screen_width = 1280;
final int screen_height = 720;
final float ball_diameter = 720/25;
final float ball_mass = ball_diameter*.1;

Ball cue_ball;
ArrayList<Ball> balls = new ArrayList<>();
PoolTable table;


void settings() {
    size(screen_width, screen_height);
}


void setup() {
    table = new PoolTable(7, 300, new PVector(screen_width/2,screen_height/2));
    cue_ball = new Ball(screen_width/2,screen_height/2, 50, 5, "white");
    cue_ball.applyForce(new PVector(0, -50));
    balls.add(cue_ball);
    
    balls.add(new Ball(screen_width/2,screen_height/2 - 200, ball_diameter, ball_mass, "red"));
    balls.add(new Ball(screen_width/2,screen_height/2 - 100, ball_diameter, ball_mass, "blue"));
}


void draw() {
  render();
  updateMovements();
}


void render() {
  background(255);
  table.draw();
  for (Ball b : balls) {
    b.draw();
  }
}


void updateMovements() {
  for (Ball b : balls) {
    b.applyDrag();
  }
  for (Ball b : balls) {
    b.move();
  }
  // check all pairs of balls for collision
  for (int i = 0; i < balls.size()-1; i++){
    for (int j = i + 1; j < balls.size(); j++){
      balls.get(i).ballCollision(balls.get(j));
    }
  }
  for (Ball b : balls) {
   table.boundaryCollision(b);
  }
}

void mousePressed() {
  balls.add(new Ball(mouseX, mouseY, 20, 2, "white"));
}
