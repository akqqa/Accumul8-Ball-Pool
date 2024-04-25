public class InvItem {
  public Ball ball;
  public int max;
  public int count;
  public int pos;
  public PVector position;
  boolean selected = false;
  boolean locked = true;

  public InvItem(float x, float y, Ball ball, int max) {
    this.ball = ball;
    this.max= max;
    this.count = max;
    this.position = new PVector(x, y);
  }
  
  public void draw() {
    // differences in appearance hinge on opacity
    
    float opacity = 180;
    if (locked) opacity = 100;
    else if (!selected && hovered()) opacity = 255;  // hovering doesn't affect if locked
    // if selected add green ring to show
    if (selected) {
      opacity = 255;
      noFill();
      stroke(58, 181, 3);
      strokeWeight(5);
      circle(position.x, position.y, ball.diameter*1.5);
    }
    // draw the ball
    ball.draw(opacity);
    // draw the count tag
    fill(255, opacity);
    rect(position.x + ball.radius, position.y + 2* ball.radius/3, 1.5*ball.radius, ball.radius, 12);
    fill(0, opacity);
    textSize(25);
    textAlign(CENTER);
    if (!locked)
      text(count, position.x + ball.radius, position.y + ball.radius);
    else {
      // if locked then no number and big red cross over the top
      text("-", position.x + ball.radius, position.y + ball.radius);
      textSize(100);
      textAlign(CENTER, CENTER);
      fill(255,0,0, 200);
      text("x", position.x, position.y);
    }

    // Draw tooltip if hovered
    if (hovered()) {
      Tooltip tooltip = new Tooltip(new PVector(mouseX, mouseY), "fire");
      tooltip.draw();
    }
  }
  
  // Function to check whether the mouse is within the item's boundary circle
  public boolean hovered() {
    if (position.dist(new PVector(mouseX, mouseY)) <= (ball.radius*1.5)) return true;
    return false;    
  }
  
  // Functions to toggle boolean flags for whether the current item is selected or locked
  public void select() { selected = true; }
  public void deselect() { selected = false; }
  public void lock() { locked = true; }
  public void unlock() { locked = false; }
  
}
