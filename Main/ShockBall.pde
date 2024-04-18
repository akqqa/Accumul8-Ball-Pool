public class ShockBall extends PowerBall {
  
  public ShockBall(float x, float y, float diameter, float mass, String colour, float powerRadius, boolean travelling, boolean impact) {
    super(x, y, diameter, mass, colour, powerRadius, travelling, impact);
    // yellow with fire insignia will do electric as blue/black with yello thunder bolt
    colourSpecific("yellow");
    //shocked = true;
  }
  
  protected void applyEffect(Ball b) {
    b.shock();
  }
}
