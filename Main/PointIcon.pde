public class PointIcon {

    public PVector position;
    public int frames;
    public float value;
    private int opacity = 255;

    public PointIcon(PVector position, int frames, float value) {
        this.position = position;
        this.frames = frames;
        this.value = value;
        this.opacity = 255;
    }

    public void draw() {
        if (frames > 0) {
            textAlign(LEFT);
            textSize(30);
            this.position.y -= 1;
            this.opacity -= 5;
            fill(212, 175, 55, opacity);
            text(str(value), position.x, position.y);
            frames -= 1;
        }
    }

}