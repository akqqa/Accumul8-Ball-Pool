public class ShockItem extends InvItem {

    public float effectRadius = 0;
    public boolean travelling = false;
    public boolean impact = true;
    public float diameter = ball_diameter;
    public float mass = ball_mass;
    public String colour = "blue";

    public ShockItem(float x, float y, Ball ball, int max) {
        super(x, y, ball, max);
        this.ball = new Ball(x, y, ball_diameter*2, 0.1, colour);
        this.ball.shocked = true;
        this.ball.powerBall = true;
    }
}
