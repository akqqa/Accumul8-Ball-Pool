final int screen_width = 1280;
final int screen_height = 720;
final float ball_diameter = 720/25;
final float pocket_diameter = 720/20;
final float ball_mass = ball_diameter*.1;

final int max_force = 100;
final float base_distance = screen_height * 0.19/* 0.2 */;
final float max_dot_product = screen_height * 0.2;

int round_num = 1;

int score = 0;
int points_needed = 80;
boolean finished = false;

boolean moving = true;
int shots = 10;

Ball cue_ball;
Cue cue;
final PVector cue_ball_start = new PVector(screen_width/2,screen_height/2 + 100);
boolean cue_ball_potted = false;
ArrayList<Ball> balls = new ArrayList<>();
ArrayList<Ball> pocketed = new ArrayList<>();
PoolTable table;
final float table_rad = 450;
Inventory inventory;
int frame = 0;
float xStart = 0;
float yStart = 0;

boolean all_ball_stop = true;

//Pocket pocket;


void settings() {
    size(screen_width, screen_height);
}


void setup() {
    frameRate(60);
    table_setup();
    inventory = new Inventory(1.25*screen_width/10, screen_height/2, screen_width/5, table_rad*1.5, shots);
    //inventory = new Inventory(0, 0, screen_width/5, table_rad*2);
}


void table_setup() {
  // For table, when 4 sides, radius 450. When any other sides, radius 325!!!
  table = new PoolTable(4, table_rad, new PVector(screen_width/2,screen_height/2), 225);
  cue_ball = new Ball(cue_ball_start.x,cue_ball_start.y, ball_diameter, ball_mass+0.5, "white");
  //cue_ball.applyForce(new PVector(0, -100));
  cue = new Cue(cue_ball.position.copy(), height * 0.3);
  balls.clear();
  balls.add(cue_ball);    
  setupTriangle(new PVector(screen_width/2,screen_height/2), 4, ball_diameter, ball_mass);
  shots = 5 + round_num;
}


void draw() {
  renderHUD();
  frame += 1;
  if (frame % 1 == 0) {
    //switch (nextTurn()) {
    //  case (0):
    //    if (cue_ball_potted) resetCueBall();
    //    // reactivate cue stick here
    //    cue.setActive(true);
    //    break;
    //  case (1):
    //    if (points_needed <= 0) {
    //      round_num ++;
    //      table_setup();
    //      points_needed = 0;
    //      // reactivate cue stick here
    //      cue.setActive(true);
    //    } else
    //      finished = true;
    //    break;
    //}
    if (finished) renderEnd();
    else {
      render();
      updateMovements();
    }
    //if (cue_ball_potted && nextTurn()) resetCueBall();
    // If the balls are moving, and now the balls have stopped, handle logic for next shot
    if (moving) {
      if (checkAllBallStop()) {
        if (shots == 0 && score < points_needed) {
          finished = true;
        } else if (score >= points_needed) {
          round_num ++;
          table_setup();
          points_needed = 0;
          if (cue_ball_potted) resetCueBall();
          cue_ball.setColour(inventory.selectedBallType());
          // reactivate cue stick here
          cue.setActive(true);
        } else {
          if (cue_ball_potted) resetCueBall();
          println(inventory.selectedBallType());
          cue_ball.setColour(inventory.selectedBallType());
          print("hi");
          cue.setActive(true);
        }
        moving = false;
      }
    } else if (checkAllBallStop() && shots != 0 && score < points_needed) {
          cue_ball.setColour(inventory.selectedBallType());
      }
  }
}

void renderHUD() {
  background(58, 181, 3);
  scale(0.98, 0.925);
  translate(2*screen_width/200, 6*screen_height/100);
  fill(0);
  textSize(30);
  textAlign(CENTER);
  text("Round " + str(round_num), 4*screen_width/5.0, -screen_height*0.02);
  textAlign(CENTER);
  text("Points Needed " + str(points_needed), 3*screen_width/5.0, -screen_height*0.02);
  textAlign(CENTER);
  if (shots < 3) fill(255, 0, 0);
  text("Shots Remaining " + str(shots), 2*screen_width/5.0, -screen_height*0.02);
  if (shots < 3) fill(0);
  textAlign(CENTER);
  text("Score " + str(score), 1*screen_width/5.0, -screen_height*0.02);
}

void renderEnd() {
  render();
  fill(255, 0, 0);
  textSize(150);
  textAlign(CENTER);
  text("GAME OVER", screen_width/2.0, screen_height/2.0);
}

void render() {
  // adjusting the rectangle position
  pushMatrix();
  translate(screen_width/2, screen_height/2);
  fill(255);
  strokeWeight(5);
  stroke(200, 0, 0);
  rect(0, 0, screen_width, screen_height, 5);
  popMatrix();
  // background(255);
  table.draw();
  inventory.draw();
  //pocket.draw();
  for (Ball b : balls) {
    b.draw();
  }
  cue.update(cue_ball.position.copy());

  if (cue.getActive()) {
    cue.display();
  }
  for (Ball b : pocketed) {
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
    if (b == cue_ball) {
      cue_ball_potted = true;
      score -= 40;
      points_needed += 40;
    } else {
      score += 20;
      points_needed -= 20;
    }
  }
}

// Takes in bottom ball of triangle, constructs rows rows of balls of radius radius
void setupTriangle(PVector bottom, int rows, float diameter, float mass) {
  for (int i = 0; i < rows; i++) {
    float startx = bottom.x - i*diameter/2;
    float starty = bottom.y - i*diameter;
    for (int j = 0; j <= i; j++) {
      balls.add(new Ball(startx + j*diameter*1.1 + random(-1,1), starty + random(-1,1), diameter, mass, "red"));
    }
  }
}

void resetCueBall() {
  cue_ball = new Ball(cue_ball_start.x,cue_ball_start.y, ball_diameter, ball_mass+0.5, "white");
  balls.add(cue_ball);
  cue_ball_potted = false;
}

int nextTurn() {
  // return -1 for still moving
  // return 0 for some reds remain
  // return 1 for no reds remain
  if (pocketed.size() > 0) return -1;
  boolean reds_remain = false;
  for (Ball b : balls)
   {
     if (b.velocity.mag() != 0) {
        return -1;
     } else if (b != cue_ball) reds_remain = true;
   }
  if (reds_remain) return 0;
  return 1;
}

void mousePressed() {
  // check for mouse within inventory
  if (inventory.mouseInInventory()) {
    inventory.selectItem();
  }
  else {
    // only lock angle when cue is active
    if (cue.getActive()) {
      loop();
      // lock the angle of the cue
      cue.setLockAngle(true);
  
      // setting up the starting position for resultant calculation
      cue.setOriginalPosition();
      xStart = mouseX;
      yStart = mouseY;
      // debug check
      // println("xStart: " + xStart);
      // println("yStart: " + yStart);
    }
  }
}

// apply resultant to the ball when the mouse is released
void mouseReleased() {
  // only apply resultant when cue is active
  if (cue.getActive() && !inventory.mouseInInventory()) {
    moving = true;
    PVector res = cue.getResultant();
    cue_ball.applyForce(res.copy());
    cue.setLockAngle(false);
    cue.setActive(false);
    inventory.useSelected();
    shots --;
  }
  
}

// check if all balls have stopped
boolean checkAllBallStop() {
  for (Ball b : balls) {
    if (b.velocity.mag() != 0) {
      //println("b.velocity.mag()" + b.velocity.mag());
      return false;
    }
  }
  for (Ball b : pocketed) {
    if (b.velocity.mag() != 0) {
      //println("b.velocity.mag()" + b.velocity.mag());
      return false;
    }
  }
  return true;
}
