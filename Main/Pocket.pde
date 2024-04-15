public class Pocket {
  
  public PVector position;
  public float diameter;
  public float radius;
  
  public Pocket(float x, float y, float diameter) {
    this.position = new PVector(x, y);
    this.diameter = diameter;
    this.radius = diameter / 2;
  }
  
  public void draw() {
    //stroke(58, 181, 3);
    //strokeWeight(1);
    //fill(58, 181, 3);     
    //circle(position.x, position.y, diameter*1.2);
    stroke(0);
    strokeWeight(0);
    fill(0);     
    circle(position.x, position.y, diameter);
  }
  
  public boolean pocketed(Ball b) {
    return pointCircle(b.position.x, b.position.y, position.x, position.y, radius) && b.velocity.mag() < 100;
  }
   
}
