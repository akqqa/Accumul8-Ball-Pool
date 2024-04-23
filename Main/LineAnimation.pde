public class LineAnimation extends Animation {

    public Ball start;
    public Ball end;
    private int opacity = 255;

    public LineAnimation(Ball start, Ball end, int frames) {
        super(frames);
        this.start = start;
        this.end = end;
        this.opacity = 255;
    }

    public void draw() {
        if (frames > 0) {
            strokeWeight(2);
            stroke(color(255, 219, 0, opacity));
            line(start.position.x, start.position.y, end.position.x, end.position.y);
            this.opacity -= 5;
            frames -= 1;
        }
    }

}
