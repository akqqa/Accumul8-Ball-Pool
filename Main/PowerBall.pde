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
  
  // to be called after all moves occur
  public void travelEffect() {
    if (!travelling) return;
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
  
  protected abstract void applyEffect(Ball b);
    
}
