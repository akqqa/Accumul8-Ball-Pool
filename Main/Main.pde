final int screen_width = 1280;
final int screen_height = 720;
final float ball_diameter = 720/25;
final float pocket_diameter = 720/20;
final float ball_mass = ball_diameter*.1;
final float cue_ball_mass = ball_mass + 0.5;
// TODO: change the round end state number
final int round_end_state = 12345;
final int game_state= 56789;
// the following are variables for menu testing
final String[] elements = {"electricity", "fire", "ice", "gravity"};
final int[] percentages = {10, 15, 20, 25};
final String[] upgrade_types = {"points", "radius"};

// electricity
int num_of_electricity_ball = 0;
float electricity_points = 1;
float electricity_radius = 1;

// fire
int num_of_fire_ball = 0;
float fire_points = 1;
float fire_radius = 1;

// ice
int num_of_ice_ball = 0;
float ice_points = 1;
float ice_radius = 1;

// gravity
int num_of_gravity_ball = 0;
float gravity_points = 1;
float gravity_radius = 1;

final int max_force = 100;
final float base_distance = screen_height * 0.19/* 0.2 */;
final float max_dot_product = screen_height * 0.2;

int state = 0;
int round_num = 0;
int[] roundScores = {2000, 40, 60, 90, 120, 150, 190, 230, 270};
int tableSides = 4;

int score = 0;
int points_needed = roundScores[0];
int points_per_ball = 10;
boolean finished = false;
ArrayList<PointIcon> pointIcons = new ArrayList<>();

boolean moving = true;

Ball cue_ball;
Cue cue;
Menu menu;
Button tempBut;
final PVector cue_ball_start = new PVector(screen_width/2,screen_height/2 + 100);
boolean cue_ball_potted = false;
ArrayList<Ball> balls = new ArrayList<>();
ArrayList<Ball> pocketed = new ArrayList<>();
PoolTable table;
final float table_rad_4 = 450;
final float table_rad_other = 325;
Inventory inventory;
int frame = 0;
float xStart = 0;
float yStart = 0;

boolean all_ball_stop = true;
boolean cue_drag = false;

InvItem currentSelectedItem = null;

// Global variables for status effects:
int fireDuration = 1;
int shockDuration = 1;
int freezeDuration = 5;
float fireMultiplier = 0.5;
float shockMultiplier = 1;
float frozenMultiplier = 1;
final float originalFireRadius = 40;
float fireRadius = 40;
final float originalShockRadius = 100;
float shockRadius = 100;
float freezeRadius = ball_diameter;

//Pocket pocket;
// sprites
PImage flame;
PImage bolt;
PImage frost;

public boolean endChecksDone = false;

void settings() {
    size(screen_width, screen_height);
}


void setup() {
    frameRate(60);
    table_setup(tableSides);
    inventory = new Inventory(1.25*screen_width/10, screen_height/2, screen_width/5, table_rad_4*1.5, 5);
    //inventory = new Inventory(0, 0, screen_width/5, table_rad*2);
    flame = loadImage("flame.png");
    bolt = loadImage("bolt.png");
    frost = loadImage("frost.png");
}


void table_setup(int sides) {
  // For table, when 4 sides, radius 450. When any other sides, radius 325!!!
  if (sides == 4) {
    table = new PoolTable(4, table_rad_4, new PVector(screen_width/2,screen_height/2), 225);
  } else {
    table = new PoolTable(sides, table_rad_other, new PVector(screen_width/2,screen_height/2), 225);
  }
  cue_ball = new Ball(cue_ball_start.x,cue_ball_start.y, ball_diameter, cue_ball_mass, "white");
  //cue_ball = new FireBall(cue_ball_start.x,cue_ball_start.y, ball_diameter, ball_mass+0.5, "black", 30, true, true);
  //cue_ball = new ShockBall(cue_ball_start.x,cue_ball_start.y, ball_diameter, ball_mass+0.5, "black", 30, true, true);
  //cue_ball.applyForce(new PVector(0, -100));
  cue = new Cue(cue_ball.position.copy(), height * 0.3);
  balls.clear();
  balls.add(cue_ball);    
  setupTriangle(new PVector(screen_width/2,screen_height/2), 4, ball_diameter, ball_mass);
  //shots = 5 * round_num+1;
}

void menu_setup() {
  menu = new Menu(screen_width * 0.85, screen_height * 0.5, 300, 700);
  // tempBut = new Button(screen_width*0.85, screen_height*0.3, 100, 50, "Test", 30, 0, 20);
}


void draw() {
  renderHUD();
  frame += 1;
  if (frame % 1 == 0) {
    if (finished) renderEnd();
    else {
      render();
      updateMovements();
    }
    //if (cue_ball_potted && nextTurn()) resetCueBall();
    // If the balls are moving, and now the balls have stopped, handle logic for next shot
    if (moving) {
      if (checkAllBallStop()) {
        // HERE WE PERFORM THE END OF ROUND PHASE
        if (!endChecksDone) { // Performs end checks once per situation where previously balls were moving, and now all stopped
          handleEndOfRoundEffects();
          endChecksDone = true;
          return;
        }
        if (!pointIcons.isEmpty()) { // the moving = false is not reached, so this will keep being reached until all pointicons have dissapeared. only then will the game move onto the next shot
          return;
        }

        endChecksDone = false;
        // Game over
        if (inventory.getBallCount() == 0 && score < points_needed) {
          finished = true;
        // Proceed to next round
        } else if (score >= points_needed) {
          inventory.resetBalls();
          switchCueBalls();
          round_num ++;
          state = round_end_state;
          if (round_num % 3 == 0 && round_num != 0) {
            tableSides = int(random(4, 10));
            print("tablesides set to" + str(tableSides));
          }
          table_setup(tableSides);
          points_needed = roundScores[round_num];
          // set up the menu
          menu_setup();
          // reactivate cue stick here
          cue.setActive(false);
          score = 0;
          //if (cue_ball_potted) resetCueBall();
          // set the cue colour to that of the selected ball in the inventory (swap to powerups)
          cue_ball.setColour(inventory.selectedBallType());
        } else {
          if (cue_ball_potted) resetCueBall();
          // set the cue colour to that of the selected ball in the inventory (swap to powerups)
          if (currentSelectedItem != inventory.selected) switchCueBalls();
          cue.setActive(true);
        }
        moving = false;
      }
    }
    // check here in case ball is stationary to allow selection change
    else if (checkAllBallStop() && inventory.getBallCount() != 0 && score < points_needed) {
      if (currentSelectedItem != inventory.selected) switchCueBalls();
    }
  }
}

void switchCueBalls() {
  // If the selected item has changed from the last frame, switch it out
  if (inventory.selected instanceof FireItem) {
    FireItem sel = (FireItem) inventory.selected;
    balls.remove(cue_ball);
    cue_ball = new FireBall(cue_ball.position.x, cue_ball.position.y, sel.diameter, sel.mass, sel.colour, fireRadius, sel.travelling,sel.impact);
    balls.add(cue_ball);
  } else if (inventory.selected instanceof ShockItem) {
    ShockItem sel = (ShockItem) inventory.selected;
    balls.remove(cue_ball);
    cue_ball = new ShockBall(cue_ball.position.x, cue_ball.position.y, sel.diameter, sel.mass, sel.colour, shockRadius, sel.travelling,sel.impact);
    balls.add(cue_ball);
  } else if (inventory.selected instanceof IceItem) {
    IceItem sel = (IceItem) inventory.selected;
    balls.remove(cue_ball);
    cue_ball = new IceBall(cue_ball.position.x, cue_ball.position.y, sel.diameter, sel.mass, sel.colour, sel.effectRadius, sel.travelling,sel.impact);
    balls.add(cue_ball);
  }else {
    balls.remove(cue_ball);
    cue_ball = new Ball(cue_ball.position.x,cue_ball.position.y, ball_diameter, cue_ball_mass, inventory.selected.ball.colourString);
    balls.add(cue_ball);
  }
  currentSelectedItem = inventory.selected;
}

void handleEndOfRoundEffects() {
  for (Ball b : balls) {
    b.hitThisShot.clear();
    if (b != cue_ball) {
      if (b.onFire) {
        score += points_per_ball * fireMultiplier;
        pointIcons.add(new PointIcon(b.position.copy(), 60, points_per_ball * fireMultiplier));
        b.effectDuration -= 1;
        if (b.effectDuration <= 0) {
          b.onFire = false;
        }
      }
      if (b.shocked) {
        b.effectDuration -= 1;
        if (b.effectDuration <= 0) {
          b.shocked = false;
        }
      }
      if (b.frozen) {
        b.effectDuration -= 1;
        if (b.effectDuration <= 0) {
          b.thaw();
        }
      }
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
  text("Round " + str(round_num + 1), 4*screen_width/5.0, -screen_height*0.02);
  textAlign(CENTER);
  text("Points Needed: " + str(points_needed), 3*screen_width/5.0, -screen_height*0.02);
  if (inventory.getBallCount() < 3) fill(0);
  textAlign(CENTER);
  text("Score: " + str(score), 2*screen_width/5.0, -screen_height*0.02);
  textAlign(CENTER);
  if (inventory.getBallCount() < 3) fill(255, 0, 0);
  text("Shots Remaining: " + str(inventory.getBallCount()), 1*screen_width/5.0, -screen_height*0.02);
  fill(0);
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
  // Draw point icons
  ArrayList<PointIcon> pointIconsCopy = new ArrayList<PointIcon>(pointIcons); // Copy to prevent concurrent modification exception
  for (PointIcon p : pointIconsCopy) {
    p.draw();
    if (p.frames <= 0) pointIcons.remove(p);
  }

  if (state == round_end_state) {
    menu.display();
    // tempBut.update();
    // tempBut.display();
  }
  if (cue.getActive() && state != round_end_state) {
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
  if (cue_ball instanceof PowerBall) ((PowerBall) cue_ball).travelEffect();
  for (Ball b : pocketed) {
    b.move();
  }
  // check all pairs of balls for collision
  for (int i = 0; i < balls.size()-1; i++){
    for (int j = i + 1; j < balls.size(); j++){
      boolean res = balls.get(i).ballCollision(balls.get(j));
      if (res) {
        if (balls.get(i) instanceof PowerBall) ((PowerBall)balls.get(i)).impactEffect(balls.get(j));
        else if (balls.get(j) instanceof PowerBall) ((PowerBall)balls.get(j)).impactEffect(balls.get(i));
      }
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
  // LOGIC FOR POTTED BALLS
  for (Ball b : bin) {
    pocketed.remove(b);
    if (b == cue_ball) {
      cue_ball_potted = true;
      score -= 10;
      pointIcons.add(new PointIcon(b.position.copy(), 60, -10));
    } else {
      score += points_per_ball;
      // Display points as icon
      pointIcons.add(new PointIcon(b.position.copy(), 60, points_per_ball));
      // IF potted ball had shock status effect, chain points to nearby balls!
      if (b.shocked) {
        for (Ball nearbyBall : balls) {
          if (dist(b.position.x, b.position.y, nearbyBall.position.x, nearbyBall.position.y) < shockRadius && nearbyBall != b && nearbyBall != cue_ball) {
            score += points_per_ball * shockMultiplier;
            pointIcons.add(new PointIcon(nearbyBall.position.copy(), 60, points_per_ball));
          }
        }
      }
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
  cue_ball = new Ball(cue_ball_start.x,cue_ball_start.y, ball_diameter, cue_ball_mass, "white");
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
  // check for mouse within inventory first
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
      cue_drag = true;
      // debug check
      // println("xStart: " + xStart);
      // println("yStart: " + yStart);
    }
  }
}

// apply resultant to the ball when the mouse is released
void mouseReleased() {
  // only apply resultant when cue is active
  if (cue.getActive() && cue_drag) { // && !inventory.mouseInInventory()) {
    moving = true;
    PVector res = cue.getResultant();
    cue_ball.applyForce(res.copy());
    cue.setLockAngle(false);
    cue.setActive(false);
    inventory.useSelected();
    cue_drag = false;
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
