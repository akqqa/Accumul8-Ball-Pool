public class InvItem {
  public Ball ball;
  public int count;
  public int pos;
  public PVector position;
  boolean selected = false;
  boolean locked = true;

  public InvItem(float x, float y, Ball ball, int count) {
    this.ball = ball;
    this.count= count;
    this.position = new PVector(x, y);
  }
  
  
  public void draw() {
    float opacity = 180;
    if (locked) opacity = 100;
    else if (!selected && hovered()) opacity = 255;
    if (selected) {
      opacity = 255;
      noFill();
      stroke(58, 181, 3);
      strokeWeight(5);
      circle(position.x, position.y, ball.diameter*1.5);
    }
    ball.draw(opacity);
    fill(255, opacity);
    rect(position.x + ball.radius, position.y + 2* ball.radius/3, 1.5*ball.radius, ball.radius, 12);
    fill(0, opacity);
    textSize(25);
    textAlign(CENTER);
    if (!locked)
      text(count, position.x + ball.radius, position.y + ball.radius);
    else {
      text("-", position.x + ball.radius, position.y + ball.radius);
      textSize(100);
      textAlign(CENTER, CENTER);
      fill(255,0,0, 200);
      text("x", position.x, position.y-10);
    }
  }
  
  public boolean hovered() {
    if (position.dist(new PVector(mouseX, mouseY)) < (ball.diameter*0.75)) return true;
    return false;    
  }
  
  public void select() { selected = true; }
  public void deselect() { selected = false; }
  public void lock() { locked = true; count = -1;}
  public void unlock() { locked = false; }
  
}
