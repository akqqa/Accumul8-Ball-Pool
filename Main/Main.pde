import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

public int frameDivider = 1;

final int screen_width = 1280;
final int screen_height = 720;
final float ball_diameter = 720/25;
final float pocket_diameter = 720/20;
final float ball_mass = ball_diameter*.1;
final int button_time = 1000;
final float cue_ball_mass = ball_mass +0.5;
// TODO: change the round end state number
final int round_end_state = 12345;
final int game_state= 56789;
// the following are variables for menu testing
final String[] elements = {"electricity", "fire", "ice", "gravity"};
final int[] percentages = {10, 15, 20, 25};
final String[] upgrade_types = {"points", "radius"};

final int max_force = 100;
final float base_distance = screen_height * 0.19/* 0.2 */;
final float max_dot_product = screen_height * 0.2;

int state = 0;
int round_num = 0;
int[] roundScores = {20, 40, 60, 85, 110, 135, 165, 195, 225};
int tableSides = 4;

float score = 0;
int points_needed = roundScores[0];
int points_per_ball = 10;
boolean finished = false;
boolean start_menu = true;
boolean win = false;
int flash_count = 0;
ArrayList<Animation> animations = new ArrayList<>();

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
PoolTable menu_table;
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
// Fire = radius and points, Shock = chains and points, Ice = duration and points, gravity = radius + points
// Duration of effect (shots)
int fireDuration;
int shockDuration;
int freezeDuration;
int freezeDurationIncrement;
int freezeDurationMax;
// Multiplier (each ball is worth a default of 10)
float fireMultiplier; // Each fire ball worth 2.5 points
float fireMultiplierIncrement;
float fireMultiplierMax;
float shockMultiplier; // Each shocked ball worth 10 points
float shockMultiplierIncrement;
float shockMultiplierMax;
// Potentially nerf so increments of 3?
float frozenMultiplier; // Each frozen ball worth 5 points
float frozenMultiplierIncrement;
float frozenMultiplierMax;
float gravityMultiplier; // Each ball pulled into a hole by gravity is worth its default amount to start
float gravityMultiplierIncrement;
float gravityMultiplierMax;
// Radius while moving
final float originalFireRadius = 20;
float fireRadius;
float fireRadiusIncrement;
float fireRadiusMax;
final float originalShockRadius = 120;
float shockRadius;
float freezeRadius = ball_diameter;
float gravityRadius;
float gravityRadiusIncrement;
float gravityRadiusMax;
// Chains for shock ball
int shockChains;
int shockChainsIncrement;
int shockChainsMax;

// The starting stats - reset every time the game is started
void resetStats() {
  fireDuration = 1;
  shockDuration = 1;
  freezeDuration = 1;
  freezeDurationIncrement = 1;
  freezeDurationMax = 4;
  fireMultiplier = 0.25; // Each fire ball worth 2.5 points
  fireMultiplierIncrement = 0.25;
  fireMultiplierMax = 1;
  shockMultiplier = 1; // Each shocked ball worth 10 points
  shockMultiplierIncrement = 0.25;
  shockMultiplierMax = 1.75;
  frozenMultiplier = 0.3; // Each frozen ball worth 3 points
  frozenMultiplierIncrement = 0.3;
  frozenMultiplierMax = 1.2;
  gravityMultiplier = 1; // Each ball pulled into a hole by gravity is worth its default amount to start
  gravityMultiplierIncrement = 0.5;
  gravityMultiplierMax = 2.5;
  // Radius while moving
  fireRadius = 30;
  fireRadiusIncrement = 10;
  fireRadiusMax = 60;
  shockRadius = 120;
  freezeRadius = ball_diameter;
  gravityRadius = 600;
  gravityRadiusIncrement = 20;
  gravityRadiusMax = 120;
  // Chains for shock ball
  shockChains = 1;
  shockChainsIncrement = 1;
  shockChainsMax = 4;
}


//Pocket pocket;
// sprites
PImage flame;
PImage bolt;
PImage frost;
PImage grav_arrow;

public boolean endChecksDone = false;
public boolean firstFrameOfShot = false;

// Minim - sound effects
Minim minim;
AudioSample ballHit;
AudioSample fireSelect;
AudioSample shockSelect;
AudioSample iceSelect;
AudioSample gravitySelect;
AudioSample wallHit;
AudioPlayer pointGain; // Audioplayer as otherwise it stacks samples on simultaneous gains and gets too loud!!
AudioSample pointLoss;
AudioSample cueHit;
AudioSample gameOver;
AudioSample gameWin;

// Font
PFont font;

void settings() {
    size(screen_width, screen_height);
}

// Resets the game state
void reset() {
  
  state = 0;
  round_num = 0;
  tableSides = int(random(4, 10));
  
  score = 0;
  points_needed = roundScores[0];
  points_per_ball = 10;
  finished = false;
  win = false;
  flash_count = 0;
  animations = new ArrayList<>();

  resetStats();

  table_setup(tableSides);
  inventory = new Inventory(1.25*screen_width/10, screen_height/2, screen_width/5, table_rad_4*1.5, 5);
}

void setup() {
    resetStats();
    frameRate(60);
    table_setup(tableSides);
    inventory = new Inventory(1.25*screen_width/10, screen_height/2, screen_width/5, table_rad_4*1.5, 5);
    flame = loadImage("flame.png");
    bolt = loadImage("bolt.png");
    frost = loadImage("frost.png");
    grav_arrow = loadImage("gravity.png");

    // Minim
    minim = new Minim(this);
    ballHit = minim.loadSample("data/sfx/ballHit.mp3");
    fireSelect = minim.loadSample("data/sfx/fireSelect.mp3");
    shockSelect = minim.loadSample("data/sfx/shockSelect.mp3");
    iceSelect = minim.loadSample("data/sfx/iceSelect.mp3");
    gravitySelect = minim.loadSample("data/sfx/gravitySelect.mp3");
    wallHit = minim.loadSample("data/sfx/wallHit.mp3");
    pointGain = minim.loadFile("data/sfx/pointGain.mp3");
    pointLoss = minim.loadSample("data/sfx/pointLoss.wav");
    cueHit = minim.loadSample("data/sfx/cueHit3.mp3");
    gameOver = minim.loadSample("data/sfx/gameOver.mp3");
    gameWin = minim.loadSample("data/sfx/gameWin.mp3");
    
    menu_table = new PoolTable(4, table_rad_4*1.9, new PVector(screen_height/2,screen_width/2), 321);
    font = createFont("joystix monospace.otf", 20);
    textFont(font);
}


void table_setup(int sides) {
  // For table, when 4 sides, radius 450. When any other sides, radius 325!!!
  if (sides == 4) {
    table = new PoolTable(4, table_rad_4, new PVector(screen_width/2,screen_height/2), 225);
  } else if (sides % 2 == 0) {
    table = new PoolTable(sides, table_rad_other, new PVector(screen_width/2,screen_height/2), 225);
  } else { // Odd table - lower position to fit correctly
    table = new PoolTable(sides, table_rad_other, new PVector(screen_width/2,screen_height/2 + 10), 225);
  }
  cue_ball = new Ball(cue_ball_start.x,cue_ball_start.y, ball_diameter, cue_ball_mass, "white");
  cue = new Cue(cue_ball.position.copy(), height * 0.3);
  balls.clear();
  balls.add(cue_ball);    
  setupTriangle(new PVector(screen_width/2,screen_height/2), 5, ball_diameter, ball_mass);
}

void menu_setup() {
  menu = new Menu(screen_width * 0.85, screen_height * 0.5, 300, 700);
  // tempBut = new Button(screen_width*0.85, screen_height*0.3, 100, 50, "Test", 30, 0, 20);
}


void draw() {
  frame += 1;
  if (frame % frameDivider == 0) {
    if (finished) renderEnd();
    else if (start_menu) renderStart();
    else {
      renderHUD();
      updateMovements();
      render();
      firstFrameOfShot = false;
    }
    // If the balls are moving, and now the balls have stopped, handle logic for next shot
    if (moving) {
      if (checkAllBallStop()) {
        endOfShot();
      }
    }
    // check here in case ball is stationary to allow selection change
    else if (checkAllBallStop() && inventory.getBallCount() != 0 && score <= points_needed) {
      if (currentSelectedItem != inventory.selected) switchCueBalls();
      for (Ball b : balls) { // Manual fix to stop gravity balls persisting after a shot
        b.gravity = false;
      }
    }
  }
}

void endOfShot() {
  // Performs end checks once per situation where previously balls were moving, and now all stopped
  if (!endChecksDone) {
    handleEndOfShotEffects();
    endChecksDone = true;
    return;
  }
  
  // the moving = false is not reached, so this will keep being reached until all animations have dissapeared. only then will the game move onto the next shot
  if (!animations.isEmpty()) {
    return;
  }
  
  endChecksDone = false;
  
  // Game over
  if (inventory.getBallCount() == 0 && score < points_needed) {
    finished = true;
    gameOver.trigger();
  }
  
  // Proceed to next round
  else if (score >= points_needed) {
    if (round_num < 8)
      nextRoundProcedure();
    else {
      finished = true;
      win = true;
      gameWin.trigger();
    }
  } 
  // Game over if 0 non-cue balls are left
  else if ((cue_ball_potted && balls.size() == 0) || (!cue_ball_potted &&  balls.size() == 1)) {
    finished = true;
    win = false;
  } 
  else {
    if (cue_ball_potted) resetCueBall();
    // switch cue balls if selected a different one
    if (currentSelectedItem != inventory.selected) switchCueBalls();
    cue.setActive(true);
  }
  moving = false;
}

// Logic for moving onto the next round
void nextRoundProcedure() {
  inventory.resetBalls();
  switchCueBalls();
  round_num ++;
  state = round_end_state;
  if (round_num % 3 == 0 && round_num != 0) {
    tableSides = int(random(4, 10));
  }
  table_setup(tableSides);
  if (round_num <= 9) { // Quick fix so game doesnt crash on win
    points_needed = roundScores[round_num];
  } else {
    points_needed = 99999;
  }
  menu_setup();
  // reactivate cue stick here
  cue.setActive(false);
  score = 0;
}

void switchCueBalls() {
  // If the selected item has changed from the last frame, switch it out
  if (inventory.selected instanceof FireItem) {
    FireItem sel = (FireItem) inventory.selected;
    balls.remove(cue_ball);
    cue_ball = new FireBall(cue_ball.position.x, cue_ball.position.y, sel.diameter, sel.mass, sel.colour, fireRadius, sel.travelling,sel.impact);
    balls.add(cue_ball);
    fireSelect.trigger();
  } else if (inventory.selected instanceof ShockItem) {
    ShockItem sel = (ShockItem) inventory.selected;
    balls.remove(cue_ball);
    cue_ball = new ShockBall(cue_ball.position.x, cue_ball.position.y, sel.diameter, sel.mass, sel.colour, shockRadius, sel.travelling,sel.impact);
    balls.add(cue_ball);
    shockSelect.trigger();
  } else if (inventory.selected instanceof IceItem) {
    IceItem sel = (IceItem) inventory.selected;
    balls.remove(cue_ball);
    cue_ball = new IceBall(cue_ball.position.x, cue_ball.position.y, sel.diameter, sel.mass, sel.colour, sel.effectRadius, sel.travelling,sel.impact);
    balls.add(cue_ball);
    iceSelect.trigger();
  } else if (inventory.selected instanceof GravityItem) {
    GravityItem sel = (GravityItem) inventory.selected;
    balls.remove(cue_ball);
    cue_ball = new GravityBall(cue_ball.position.x, cue_ball.position.y, sel.diameter, sel.mass, sel.colour, gravityRadius, sel.travelling, sel.impact);
    balls.add(cue_ball);
    gravitySelect.trigger();
  } else {
    balls.remove(cue_ball);
    cue_ball = new Ball(cue_ball.position.x,cue_ball.position.y, ball_diameter, cue_ball_mass, inventory.selected.ball.colourString);
    balls.add(cue_ball);
  }
  currentSelectedItem = inventory.selected;
}

// Handles effect durations at the end of a shot
void handleEndOfShotEffects() {
  for (Ball b : balls) {
    b.hitThisShot.clear();
    if (b != cue_ball) {
      if (b.onFire) {
        score += points_per_ball * fireMultiplier;
        animations.add(new PointIcon(b.position.copy(), 60, points_per_ball * fireMultiplier));
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
      if (b.gravity) {
        b.gravity = false; // Should always end after shot
      }
    }
  }
}

// Render the start screen
void renderStart() {
  translate(screen_width, 0);
  rotate(HALF_PI);
  menu_table.draw();
  rotate(HALF_PI);
  rotate(PI);
  translate(-screen_width, 0);
  textAlign(CENTER);
  fill(255);
  if (flash_count < 50) {
    textSize(40);
    text("LEFT MOUSE click to start", screen_width/2, 2.5*screen_height/5);
    textSize(30);
    text("TURN ON THE VOLUME", screen_width/2, 3*screen_height/5);
  } else if (flash_count > 100) flash_count = 0;
  textSize(55);
  text("Accumul8-ball Pool", screen_width/2, 2*screen_height/5);
  flash_count ++;
}

// Render the HUD
void renderHUD() {
  background(58, 181, 3);
  scale(0.98, 0.925);
  translate(2*screen_width/200, 6*screen_height/100);
  fill(0);
  textSize(20);
  textAlign(CENTER);
  text("Round " + str(round_num + 1), 8*screen_width/9.0, -screen_height*0.02);
  textAlign(CENTER);
  text("Points Needed: " + str(points_needed), 5*screen_width/8.0, -screen_height*0.02);
  if (inventory.getBallCount() < 3) fill(0);
  textAlign(CENTER);
  text("Score: " + str(score), 3*screen_width/8.0, -screen_height*0.02);
  textAlign(CENTER);
  if (inventory.getBallCount() < 3) fill(255, 0, 0);
  text("Shots Remaining: " + str(inventory.getBallCount()), 1*screen_width/8.0, -screen_height*0.02);
  fill(0);
}

// Render game over / win screen
void renderEnd() {
  translate(screen_width, 0);
  rotate(HALF_PI);
  menu_table.draw();
  rotate(HALF_PI);
  rotate(PI);
  translate(-screen_width, 0);
  textAlign(CENTER);
  fill(255);
  if (flash_count < 50) {
    textSize(40);
    text("LEFT MOUSE click to restart", screen_width/2, 3*screen_height/5);
  } else if (flash_count > 100) flash_count = 0;
  textSize(55);
  text("GAME OVER", screen_width/2, 2*screen_height/5);
  if (win) text("PLAYER WINS", screen_width/2, 2.5*screen_height/5);
  else text("PLAYER LOSES", screen_width/2, 2.5*screen_height/5);
  flash_count ++;
}

void render() {
  // adjusting the rectangle position
  pushMatrix();
  translate(screen_width/2, screen_height/2);
  fill(196, 245, 174);
  strokeWeight(5);
  stroke(200, 0, 0);
  rect(0, 0, screen_width, screen_height, 5);
  popMatrix();
  table.draw();
  for (Ball b : balls) {
    b.draw();
  }
  cue.update(cue_ball.position.copy());
  // Draw point icons
  ArrayList<Animation> animationsCopy = new ArrayList<Animation>(animations); // Copy to prevent concurrent modification exception
  for (Animation p : animationsCopy) {
    p.draw();
    if (p.frames <= 0) animations.remove(p);
  }

  if (state == round_end_state) {
    menu.display();
  }
  if (cue.getActive() && state != round_end_state) {
    cue.display();
  }
  for (Ball b : pocketed) {
    b.draw();
  }
  inventory.draw();
}

// Update the movements of all balls every frame
void updateMovements() {
  for (Ball b : balls) {
    b.applyDrag();
  }
  if (cue_ball instanceof PowerBall) ((PowerBall) cue_ball).travelEffect();
  for (Ball b : pocketed) {
    b.move();
  }
  // check all pairs of balls for collision
  for (int i = 0; i < balls.size()-1; i++){
    for (int j = i + 1; j < balls.size(); j++){
      boolean res;

      if (balls.get(balls.size()-1) == cue_ball) { // If the final ball is the cue ball, must switch the order of collisions. Otherwise the cue ball is slightly less accurate, leading to incorrect aim lines
        res = balls.get(j).ballCollision(balls.get(i));
      } else {
        res = balls.get(i).ballCollision(balls.get(j));
      }
      if (res) {
        if (balls.get(i) instanceof PowerBall) ((PowerBall)balls.get(i)).impactEffect(balls.get(j));
        else if (balls.get(j) instanceof PowerBall) ((PowerBall)balls.get(j)).impactEffect(balls.get(i));
      }
    }
  }
  // Unsure why, but having movement after boundary collisions actually stops balls phasing out of boundaries
  for (Ball b : balls) {
   table.boundaryCollision(b);
   if (table.ballInPocket(b)) pocketed.add(b);
  }
  for (Ball b : balls) {
    b.move();
  }
  
  
  ArrayList<Ball> bin = new ArrayList<>();
  for (Ball b : pocketed) {
    if (b == cue_ball && cue_ball instanceof GravityBall) {
      ((PowerBall) b).pocketEffect();
    }
    balls.remove(b);
    if (table.ballFinished(b)) bin.add(b);
  }
  // LOGIC FOR POTTED BALLS
  for (Ball b : bin) {
    pocketed.remove(b);
    if (b == cue_ball) {
      cue_ball_potted = true;
      if (! (b instanceof GravityBall)) {
        score -= 10;
        animations.add(new PointIcon(b.position.copy(), 60, -10));
      }
    } else {
      if (b.shocked) {
        score += points_per_ball * shockMultiplier;
        animations.add(new PointIcon(b.position.copy(), 60, points_per_ball*shockMultiplier));
        // Handle shock effect
        handleShockChain(b);
      } else {
        if (b.gravity) {
          score += points_per_ball * gravityMultiplier;
          animations.add(new PointIcon(b.position.copy(), 60, points_per_ball * gravityMultiplier));
        }
        else {
          score += points_per_ball;
          animations.add(new PointIcon(b.position.copy(), 60, points_per_ball));
        }
      }

    }
  }
}

void handleShockChain(Ball ball) {
  ArrayList<Ball> ballsToHandleShock = new ArrayList<Ball>();
  ArrayList<Ball> newBallsToHandleShock = new ArrayList<Ball>();
  ballsToHandleShock.add(ball);
  ArrayList<Ball> shockedBalls = new ArrayList<Ball>();
  shockedBalls.add(ball);
  // Repeat for number of chains the player has unlocked
  for (int i = 0; i < shockChains; i++) {
    ArrayList<Ball> candidateBalls = new ArrayList<Ball>();
    // Iterate through each ball that should be handled. Every iteration of chain means new balls are handled
    for (Ball b : ballsToHandleShock) {
      int ballsShocked = 0;
      for (Ball nearbyBall : balls) {
        if (ballsShocked == 2) {
          break;
        }
        // If within radius, add to a list of candidate balls. of which the two balls closest to the ball will be chosen
        if (dist(b.position.x, b.position.y, nearbyBall.position.x, nearbyBall.position.y) < (shockRadius + nearbyBall.radius) && nearbyBall != b && nearbyBall != cue_ball && !shockedBalls.contains(nearbyBall)) {
          // Add to list
          candidateBalls.add(nearbyBall);
        }
      }
      // Hacky way of getting the two closest balls from the candidate balls
      if (candidateBalls.isEmpty()) {
        continue;
      }
      ArrayList<Ball> closestBalls = new ArrayList<Ball>();
      Ball closestBall = candidateBalls.get(0);
      for (Ball cBall : candidateBalls) {
        if (dist(b.position.x, b.position.y, cBall.position.x, cBall.position.y) < dist(b.position.x, b.position.y, closestBall.position.x, closestBall.position.y)) {
          closestBall = cBall;
        }
      }
      closestBalls.add(closestBall);
      candidateBalls.remove(closestBall);
      if (!candidateBalls.isEmpty()) {
        closestBall = candidateBalls.get(0);
        for (Ball cBall : candidateBalls) {
          if (dist(b.position.x, b.position.y, cBall.position.x, cBall.position.y) < dist(b.position.x, b.position.y, closestBall.position.x, closestBall.position.y)) {
            closestBall = cBall;
          }
        }
        closestBalls.add(closestBall);
      }
      // These two closest balls are the ones that get shocked
      for (Ball closeBall : closestBalls) {
          // Extra check for shocklist as sometimes it doesnt seem to check properly
          if (shockedBalls.contains(closeBall)) {
            continue;
          }
          // Draw a line between the two balls
          animations.add(new LineAnimation(b, closeBall, 60));
          score += points_per_ball * shockMultiplier * pow(0.5, i);
          animations.add(new PointIcon(closeBall.position.copy(), 60, points_per_ball * shockMultiplier * pow(0.5, i)));
          // Add ball to both lists
          newBallsToHandleShock.add(closeBall);
          shockedBalls.add(closeBall);
          ballsShocked += 1;
      }
    }
    ballsToHandleShock = new ArrayList<Ball>(newBallsToHandleShock);
    newBallsToHandleShock = new ArrayList<Ball>();
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
  balls.remove(cue_ball);
  cue_ball = new Ball(cue_ball_start.x,cue_ball_start.y, ball_diameter, cue_ball_mass, "white");
  balls.add(cue_ball);
  cue_ball_potted = false;
  switchCueBalls();
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

void keyPressed() {

  if (key == ' ') {
    frameDivider = 20;
  }

}

void mousePressed() {
  if (finished) {
    finished = false;
    start_menu = true;
    return;
  }
  if (start_menu) {
    start_menu = false;
    reset();
    return;
  }
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
    }
  }
}

// apply resultant to the ball when the mouse is released
void mouseReleased() {
  // only apply resultant when cue is active
  if (cue.getActive() && cue_drag && cue.getResultant().mag() != 0) { // && !inventory.mouseInInventory()) {
    cueHit.trigger();
    moving = true;
    PVector res = cue.getResultant();
    cue_ball.applyForce(res.copy());
    cue.setLockAngle(false);
    cue.setActive(false);
    inventory.useSelected();
    cue_drag = false;
  } else if (cue.getActive() && cue_drag) {
    cue.setLockAngle(false);
    cue_drag = false;
  }
}


// check if all balls have stopped
boolean checkAllBallStop() {
  for (Ball b : balls) {
    if (b.velocity.mag() != 0) {
      return false;
    }
  }
  for (Ball b : pocketed) {
    if (b.velocity.mag() != 0) {
      return false;
    }
  }
  return true;
}
