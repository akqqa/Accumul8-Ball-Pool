public class FireBall extends PowerBall {
  
  public FireBall(float x, float y, float diameter, float mass, String colour, float powerRadius, boolean travelling, boolean impact) {
    super(x, y, diameter, mass, colour, powerRadius, travelling, impact);
    colourSpecific("orange");
    onFire = true;
    powerBall = true;
  }
  
  protected void applyEffect(Ball b) {
    b.alight();
  }
}
