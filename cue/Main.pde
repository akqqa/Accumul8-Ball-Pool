Cue cue;
int screen_width = 1280;
int screen_height = 720;
float xStart = 0;
float yStart = 0;
final float BASE_DISTANCE = screen_height * 0.19/* 0.2 */;
final float MAX_DOT_PRODUCT = screen_height * 0.2;
int startTime;
PVector ballPosition;
PVector ballVelocity;
void settings() {
    size(screen_width, screen_height);
}
void setup() {
    background(0);
    // temporary position for the ball
    ballPosition = new PVector(200, 200);
    ballVelocity = new PVector(0, 0);
    cue = new Cue(ballPosition.copy().x, ballPosition.copy().y, height * 0.3);
}

void draw() {
  background(0);
  // update cue according to mouse position
  cue.update(ballPosition);

  // drawing the cue ball
  ellipse(ballPosition.x, ballPosition.y, 30, 30);
  // TODO: simulating the ball moving, only draw cue when ball is at rest
  if (millis() - startTime > 1000) {
    ballVelocity.x = 0;
    ballVelocity.y = 0;
  }
  // drawing the cue
  if (ballVelocity.copy().x == 0 && ballVelocity.copy().y == 0) {
    cue.display();
  }
  
}

void mousePressed() {
    // lock the angle of the cue
    cue.setLockAngle(true);

    // setting up the starting position for resultant calculation
    cue.setOriginalPosition();
    xStart = mouseX;
    yStart = mouseY;
    // debug check
    println("xStart: " + xStart);
    println("yStart: " + yStart);
}

// apply resultant to the ball when the mouse is released
void mouseReleased() {
    PVector res = cue.getResultant();
    ballPosition.x += res.x;
    ballPosition.y += res.y;
    // simulating ball moving
    startTime = millis();
    ballVelocity = new PVector(res.x, res.y);

    cue.setLockAngle(false);
}
