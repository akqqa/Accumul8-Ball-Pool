public class Tooltip {
    
    protected PVector position;
    protected String ballType;

    public Tooltip(PVector position, String type) {
        this.ballType = type;
        this.position = position;
    }

    public void draw() {
        // Draw a box
        rectMode(CORNER);
        rect(position.x, position.y, 200, 100);
        if (ballType.equals("fire")) {
            text("Points: " + fireMultiplier*points_per_ball + " ( "+ fireMultiplierMax*points_per_ball+" max)", position.x+5, position.y + 5);
        }
    }
}