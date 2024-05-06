// The animated floating point indicator when points are scored
public class PointIcon extends Animation {

    public PVector position;
    public float value;
    private int opacity = 255;

    public PointIcon(PVector position, int frames, float value) {
        super(frames);
        this.position = position;
        this.value = value;
        this.opacity = 255;
        // Play relevant sound effect
        if (value < 0) {
            pointLoss.trigger();
        } else {
            pointGain.rewind();
            pointGain.play();
        }
    }

    public void draw() {
        // Float upwards and decrease opacity
        if (frames > 0) {
            textAlign(LEFT);
            textSize(30);
            this.position.y -= 1;
            this.opacity -= 5;
            if (value > 0) {
                fill(212, 175, 55, opacity);
            } else {
                fill(139, 0, 0, opacity);
            }
            text(str(value), position.x, position.y);
            frames -= 1;
        }
    }

}