public class LineAnimation extends Animation {

    public PVector start;
    public PVector end;
    private int opacity = 255;

    public LineAnimation(PVector start, PVector end, int frames) {
        super(frames);
        this.start = start;
        this.end = end;
        this.opacity = 255;
    }

    public void draw() {
        if (frames > 0) {
            strokeWeight(2);
            stroke(color(255, 219, 0, opacity));
            line(start.x, start.y, end.x, end.y);
            this.opacity -= 5;
            frames -= 1;
        }
    }

}
