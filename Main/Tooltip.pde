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
        fill(255,255,255);
        rect(mouseX, mouseY, 200, 100);
        if (ballType.equals("fire")) {
            textSize(10);
            textAlign(LEFT);
            fill(0,0,0);
            text("Points: " + fireMultiplier*points_per_ball + " ( "+ fireMultiplierMax*points_per_ball+" max)", mouseX+10, mouseY + 10);
        }
        rectMode(CENTER);
    }
}