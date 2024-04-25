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
        rect(mouseX, mouseY, 550, 170);
        textSize(20);
        textAlign(LEFT);
        fill(0,0,0);
        if (ballType.equals("regular")) {
            text("Cue Ball.", mouseX + 10, mouseY + 20);
            text("A regular cue ball.", mouseX + 10, mouseY + 80);
            text("Points: " + points_per_ball, mouseX+10, mouseY + 140);
        }
        else if (ballType.equals("fire")) {
            text("Fire Ball.", mouseX + 10, mouseY + 20);
            text("Lights balls nearby on fire,", mouseX + 10, mouseY + 50);
            text("which give points after each", mouseX + 10, mouseY + 70);
            text("shot.", mouseX + 10, mouseY + 90);
            text("Points: " + fireMultiplier*points_per_ball + " ("+ fireMultiplierMax*points_per_ball+" max)", mouseX+10, mouseY + 120);
            text("Radius: " + fireRadius + " ("+ fireRadiusMax+" max)", mouseX+10, mouseY + 150);
        } else if (ballType.equals("shock")) {
            text("Shock Ball.", mouseX + 10, mouseY + 20);
            text("Balls pocketed with this shoot", mouseX + 10, mouseY + 50);
            text("lightning at nearby balls,", mouseX + 10, mouseY + 70);
            text("giving bonus points for each.", mouseX + 10, mouseY + 90);
            text("Points: " + shockMultiplier*points_per_ball + " ("+ shockMultiplierMax*points_per_ball+" max)", mouseX+10, mouseY + 120);
            text("Chains: " + shockChains + " ("+ shockChainsMax+" max)", mouseX+10, mouseY + 150);
        } else if (ballType.equals("ice")) {
            text("Ice Ball.", mouseX + 10, mouseY + 20);
            text("Balls hit with this are frozen", mouseX + 10, mouseY + 50);
            text("in place, giving bonus points", mouseX + 10, mouseY + 70);
            text("when hit.", mouseX + 10, mouseY + 90);
            text("Points: " + shockMultiplier*points_per_ball + " ("+ shockMultiplierMax*points_per_ball+" max)", mouseX+10, mouseY + 120);
            text("Freeze Duration: " + freezeDuration + " ("+ freezeDurationMax+" max)", mouseX+10, mouseY + 150);
        } else if (ballType.equals("gravity")) {
            text("Gravity Ball.", mouseX + 10, mouseY + 20);
            text("Nearby balls move towards this", mouseX + 10, mouseY + 50);
            text("ball. When this ball is pocketed", mouseX + 10, mouseY + 70);
            text("it incurs no penalty and", mouseX + 10, mouseY + 90);
            text("attracts nearby balls.", mouseX + 10, mouseY + 110);
            text("Points: " + shockMultiplier*points_per_ball + " ("+ shockMultiplierMax*points_per_ball+" max)", mouseX+10, mouseY + 140);
            text("Radius: " + gravityRadius + " ("+ gravityRadiusMax + " max)", mouseX+10, mouseY + 160);
        }
        rectMode(CENTER);
    }
}