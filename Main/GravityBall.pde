public class GravityBall extends PowerBall {
  
  public GravityBall(float x, float y, float diameter, float mass, String colour, float powerRadius, boolean travelling, boolean impact) {
    super(x, y, diameter, mass, colour, powerRadius, travelling, impact);
    colourSpecific("black");
    gravity = true;
    powerBall = true;
  }
  
  protected void applyEffect(Ball b) {
    b.pull(this);
  }
}
