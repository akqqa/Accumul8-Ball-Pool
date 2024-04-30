public class IceItem extends InvItem {

    public float effectRadius = ball_diameter/2+1;
    public boolean travelling = true;
    public boolean impact = false;
    public float diameter = ball_diameter;
    public float mass = cue_ball_mass;
    public String colour = "lightblue";

    public IceItem(float x, float y, Ball ball, int max) {
        super(x, y, ball, max);
        this.ball = new Ball(x, y, ball.diameter, 0.1, colour);
        this.ball.frozen = true;
        this.ball.powerBall = true;
    }
}
