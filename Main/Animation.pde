public abstract class Animation {

    public int frames;

    public Animation(int frames) {
        this.frames = frames;
    }

    public abstract void draw();
}