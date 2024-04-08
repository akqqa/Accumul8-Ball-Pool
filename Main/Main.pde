final int screen_width = 1280;
final int screen_height = 720;
final float ball_diameter = 720/25;
final float ball_mass = ball_diameter*.1;

Ball cue_ball;
ArrayList<Ball> balls = new ArrayList<>();


void settings() {
    size(screen_width, screen_height);
}


void setup() {
    cue_ball = new Ball(20, 20, 50, 5, "white");
    cue_ball.applyForce(new PVector(20, 20));
    balls.add(cue_ball);
    
    balls.add(new Ball(50, 50, ball_diameter, ball_mass, "red"));
    balls.add(new Ball(100, 50, ball_diameter, ball_mass, "blue"));
    balls.add(new Ball(50, 100, ball_diameter, ball_mass, "pink"));
    balls.add(new Ball(100, 100, ball_diameter, ball_mass, "brown"));
    balls.add(new Ball(200, 100, ball_diameter, ball_mass, "yellow"));
    balls.add(new Ball(100, 200, ball_diameter, ball_mass, "black"));
}


void draw() {
  render();
  updateMovements();
}


void render() {
  background(255);
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
  //for (Ball b : balls) {
  //  table.boundaryCollision(b);
  //}
  for (int i = 0; i < balls.size()-1; i++){
      for (int j = i + 1; j < balls.size(); j++){
        balls.get(i).ballCollision(balls.get(j));
      }
  }
}

void mousePressed() {
  balls.add(new Ball(mouseX, mouseY, 20, 2, "white"));
}
