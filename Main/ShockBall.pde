public class ShockBall extends PowerBall {
  
  public ShockBall(float x, float y, float diameter, float mass, String colour, float powerRadius, boolean travelling, boolean impact) {
    super(x, y, diameter, mass, colour, powerRadius, travelling, impact);
    colourSpecific("blue");
    shocked = true;
    powerBall = true;
  }
  
  protected void applyEffect(Ball b) {
    b.shock();
  }
}
