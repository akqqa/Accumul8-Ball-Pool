public class GravityItem extends InvItem {

    public float effectRadius = 200;
    public boolean travelling = true;
    public boolean impact = false;
    public float diameter = ball_diameter;
    public float mass = cue_ball_mass;
    public String colour = "black";

    public GravityItem(float x, float y, Ball ball, int max) {
        super(x, y, ball, max);
        this.ball = new Ball(x, y, ball_diameter*2, 0.1, colour);
        this.ball.gravity = true;
        this.ball.powerBall = true;
    }
}
