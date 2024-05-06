// Abstract class for animations, so that all animations can be held in a single list
public abstract class Animation {

    public int frames;

    public Animation(int frames) {
        this.frames = frames;
    }

    public abstract void draw();
}