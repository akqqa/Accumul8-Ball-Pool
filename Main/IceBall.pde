public class IceBall extends PowerBall {
  
  public IceBall(float x, float y, float diameter, float mass, String colour, float powerRadius, boolean travelling, boolean impact) {
    super(x, y, diameter, mass, colour, powerRadius, travelling, impact);
    colourSpecific("lightblue");
    frozen = true;
    powerBall = true;
  }
  
  protected void applyEffect(Ball b) {
    b.freeze();
  }
}
