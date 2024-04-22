public abstract class PowerBall extends Ball{

  protected float powerRadius;
  protected boolean travelling, impact;
  
  public PowerBall(float x, float y, float diameter, float mass, String colour, float powerRadius, boolean travelling, boolean impact) {
    super(x, y, diameter, mass, colour);
    this.powerRadius = powerRadius;
    // booleans to indicate whether power applies during travel or on impact
    this.travelling = travelling;
    this.impact = impact;
  }
  
  public void draw() {
      stroke(0,0,0);
      strokeWeight(1);
      if (velocity.x != 0 || velocity.y != 0) {
         noStroke();
         fill(colour, 150);
         circle (position.x, position.y, powerRadius*2);
         stroke(0,0,0);
      }
      fill(colour);     
      circle(position.x, position.y, diameter);
      power(255);
    }
  
  // to be called after all moves occur
  public void travelEffect() {
    if (!travelling) return;
    if (velocity.x == 0 && velocity.y == 0) return;
    radialEffect();
  }
  
  private void radialEffect() {
    for (Ball b : balls) {
      // if not the cue ball and the ball is within powerradius -> attack
      if (b != this && circleCircle(position.x, position.y, powerRadius, b.position.x, b.position.y, b.radius)) {
        applyEffect(b);
      }
    }
  }
  
  // to be called on contact with a ball
  public void impactEffect(Ball b) {
    if (!impact) return;
    applyEffect(b);
    travelEffect();
  }
  
  // to be called when pocketed
  public void pocketEffect() {
    radialEffect();
  }
  
  protected abstract void applyEffect(Ball b);
    
}
