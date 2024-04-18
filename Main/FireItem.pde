public class FireItem extends InvItem {

    public float effectRadius = 20;
    public boolean travelling = true;
    public boolean impact = false;
    public float diameter = ball_diameter;
    public float mass = ball_mass;
    public String colour = "orange";

    public FireItem(float x, float y, Ball ball, int max) {
        super(x, y, ball, max);
        this.ball = new Ball(x, y, ball_diameter*2, 0.1, "orange");
        this.ball.onFire = true;
    }
}
