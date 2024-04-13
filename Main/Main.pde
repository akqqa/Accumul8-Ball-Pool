final int screen_width = 1280;
final int screen_height = 720;
final float ball_diameter = 720/25;
final float pocket_diameter = 720/20;
final float ball_mass = ball_diameter*.1;

int round_num = 0;
int score = 0;
int points_needed = 0;

Ball cue_ball;
ArrayList<Ball> balls = new ArrayList<>();
ArrayList<Ball> pocketed = new ArrayList<>();
PoolTable table;
int frame = 0;

//Pocket pocket;


void settings() {
    size(screen_width, screen_height);
}


void setup() {
    frameRate(60);
    table = new PoolTable(4, 300, new PVector(screen_width/2,screen_height/2));
    cue_ball = new Ball(screen_width/2,screen_height/2 + 100, ball_diameter, ball_mass+0.5, "white");
    cue_ball.applyForce(new PVector(0, -100));
    balls.add(cue_ball);
    
    //balls.add(new Ball(screen_width/2,screen_height/2 - 175, ball_diameter, ball_mass, "red"));
    //balls.add(new Ball(screen_width/2,screen_height/2 - 100, ball_diameter, ball_mass, "blue"));
    
    setupTriangle(new PVector(screen_width/2,screen_height/2), 4, ball_diameter, ball_mass);
    
    //pocket = new Pocket(screen_width/2, screen_height/2-200, pocket_diameter);
}


void draw() {
  renderHUD();
  frame += 1;
  if (frame % 1 == 0) {
    render();
    updateMovements();
  }
}

void renderHUD() {
  background(58, 181, 3);
  scale(0.98, 0.95);
  translate(2*screen_width/200, 4*screen_height/100);
  fill(0);
  textSize(15);
  textAlign(CENTER);
  text("Round " + str(round_num), 4*screen_width/6.0, -screen_height*0.01);
  textAlign(CENTER);
  text("Points Needed " + str(points_needed), 3*screen_width/6.0, -screen_height*0.01);
  textAlign(CENTER);
  text("Score " + str(score), 2*screen_width/6.0, -screen_height*0.01);
}

void render() {
  fill(255);
  strokeWeight(5);
  stroke(200, 0, 0);
  rect(0, 0, screen_width, screen_height);
  //background(255);
  table.draw();
  //pocket.draw();
  for (Ball b : balls) {
    b.draw();
  }
  for (Ball b : pocketed) {
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
  for (Ball b : pocketed) {
    b.move();
  }
  // check all pairs of balls for collision
  for (int i = 0; i < balls.size()-1; i++){
    for (int j = i + 1; j < balls.size(); j++){
      balls.get(i).ballCollision(balls.get(j));
    }
  }
  for (Ball b : balls) {
    // Slight logical error here - since ball velocity can be changed by a collision, the method of going back using velocity isnt quite correct. only fix this if there is an actual error with balls phasing out of table in the game
   table.boundaryCollision(b);
   if (table.ballInPocket(b)) pocketed.add(b);
  }
  ArrayList<Ball> bin = new ArrayList<>();
  for (Ball b : pocketed) {
    balls.remove(b);
    if (table.ballFinished(b)) bin.add(b);
  }
  for (Ball b : bin) {
    pocketed.remove(b);
  }
}

// Takes in bottom ball of triangle, constructs rows rows of balls of radius radius
void setupTriangle(PVector bottom, int rows, float radius, float mass) {
  for (int i = 0; i < rows; i++) {
    float startx = bottom.x - i*radius/2;
    float starty = bottom.y - i*radius;
    for (int j = 0; j <= i; j++) {
      balls.add(new Ball(startx + j*radius*1.1 + random(-1,1), starty + random(-1,1), radius, mass, "red"));
    }
  }
}

void mousePressed() {
  loop();
  //balls.add(new Ball(mouseX, mouseY, 20, 2, "white"));
}
