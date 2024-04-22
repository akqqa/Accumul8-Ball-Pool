public class GravityItem extends InvItem {

    public float effectRadius = ball_diameter/2+1;
    public boolean travelling = false;
    public boolean impact = false;
    public float diameter = ball_diameter;
    public float mass = ball_mass;
    public String colour = "black";

    public GravityItem(float x, float y, Ball ball, int max) {
        super(x, y, ball, max);
        this.ball = new Ball(x, y, ball_diameter*2, 0.1, colour);
        this.ball.gravity = true;
        this.ball.powerBall = true;
    }
}
