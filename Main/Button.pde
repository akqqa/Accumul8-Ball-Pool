public class Button {
    protected PVector position;
    protected float button_width;
    protected float button_height;
    protected float button_amount;
    protected String button_element;
    protected String button_type;
    protected String button_text;
    protected color button_color;
    protected boolean button_clicked;
    protected boolean button_over;
    protected int startTime = 0;
    protected int xAdjustmentLeft = 7;
    protected int xAdjustmentRight = 12;
    protected int yUpgradesAdjustment0 = 20;
    
    protected int yUpgradesAdjustmentTop1 = 20;
    protected int yUpgradesAdjustmentBot1 = 20;
    protected int yUpgradesAdjustmentTop2 = 17;
    protected int yUpgradesAdjustmentBot2 = 15;
    protected int yBallAdjustmentTop0 = 10;
    protected int yBallAdjustmentBot0 = 7;
    protected int yBallAdjustmentTop1 = 5;
    protected int yBallAdjustmentBot1 = 2;
    protected int yGenAdjustmentBot = 5;
    
    // button constructor, taking in x, y coordinates, width, height, amount (for upgrade or ball addition), element, type(points, radius, upgrade or confirmation)
    public Button (float _x, float _y, float _width, float _height, float _amount, String _element, String _type/* , int _r, int _g, int _b */) {
        this.position = new PVector(_x, _y);
        this.button_width = _width;
        this.button_height = _height;
        this.button_amount = _amount;
        this.button_element = _element;
        this.button_type = _type;
        // this.button_color = color(_r, _g, _b);

        // check the type of the button and set the text accoerdingly
        if (this.button_type.equals("points") || this.button_type.equals("radius") ) {
            // type for upgrade
            this.button_text = "+" + button_amount + "% " + this.button_element + " " + this.button_type;
        } else if (this.button_type.equals("ball")) {
            // type for elemental ball addition
            this.button_text = "+" + button_amount + " " + this.button_element + " "+ this.button_type;
        } else if (this.button_type.equals("confirmation")) {
            // confirmation button
            this.button_text = "Confirm";
        } else if (this.button_type.equals("skip")) {
            // skip button
            this.button_text = "Skip";
        } else {
            this.button_text = "null";
        }
        

        this.button_clicked = false;
        this.button_over = false;
    }

    // Manually set text of button from outside
    public void setText(String text) {
        this.button_text = text;
    }

    // update function checks if the cursor is over the button and if the user clicks
    public void update(int index) {
        if ((this.button_type.equals("points") || this.button_type.equals("radius") || this.button_type.equals("chains") || this.button_type.equals("duration")) && (index == 0) &&
            mouseX >= this.position.copy().x - /* round( */this.button_width/ 2 - xAdjustmentLeft/* /2 + 1) */ && mouseX <= this.position.copy().x + /* round( */this.button_width/2 - xAdjustmentRight/* /2-1) */ &&
            mouseY >= (this.position.copy().y - /* round( */ this.button_height/2 + yUpgradesAdjustment0 /* /2 + 1) */) && mouseY <= (this.position.copy().y + /* round( */this.button_height/2 + yUpgradesAdjustment0/* /2-1) */)) {
            // background(125);
            this.button_over = true;
        } else if ((this.button_type.equals("points") || this.button_type.equals("radius") || this.button_type.equals("chains") || this.button_type.equals("duration")) && (index == 1) &&
            mouseX >= this.position.copy().x - /* round( */this.button_width/ 2 - xAdjustmentLeft/* /2 + 1) */ && mouseX <= this.position.copy().x + /* round( */this.button_width/2 - xAdjustmentRight/* /2-1) */ &&
            mouseY >= (this.position.copy().y - /* round( */ this.button_height/2 + yUpgradesAdjustmentTop1 /* /2 + 1) */) && mouseY <= (this.position.copy().y + /* round( */this.button_height/2 + yUpgradesAdjustmentBot1/* /2-1) */)) {
            // background(0);
            this.button_over = true;
        } else if ((this.button_type.equals("points") || this.button_type.equals("radius") || this.button_type.equals("chains") || this.button_type.equals("duration")) && (index == 2) &&
            mouseX >= this.position.copy().x - /* round( */this.button_width/ 2 - xAdjustmentLeft/* /2 + 1) */ && mouseX <= this.position.copy().x + /* round( */this.button_width/2 - xAdjustmentRight/* /2-1) */ &&
            mouseY >= (this.position.copy().y - /* round( */ this.button_height/2 + yUpgradesAdjustmentTop2 /* /2 + 1) */) && mouseY <= (this.position.copy().y + /* round( */this.button_height/2 + yUpgradesAdjustmentBot2/* /2-1) */)) {
            // background(125);
            this.button_over = true;
        } else if (this.button_type.equals("ball") && (index == 0) &&
            mouseX >= this.position.copy().x - /* round( */this.button_width/ 2 - xAdjustmentLeft/* /2 + 1) */ && mouseX <= this.position.copy().x + /* round( */this.button_width/2 - xAdjustmentRight/* /2-1) */ &&
            mouseY >= this.position.copy().y - /* round( */ this.button_height/2 + yBallAdjustmentTop0 /* /2 + 1) */ && mouseY <= this.position.copy().y + /* round( */this.button_height/2 + yBallAdjustmentBot0/* /2-1) */) {
            
            this.button_over = true;
        } else if (this.button_type.equals("ball") && (index != 0) &&
            mouseX >= this.position.copy().x - /* round( */this.button_width/ 2 - xAdjustmentLeft/* /2 + 1) */ && mouseX <= this.position.copy().x + /* round( */this.button_width/2 - xAdjustmentRight/* /2-1) */ &&
            mouseY >= this.position.copy().y - /* round( */ this.button_height/2 + yBallAdjustmentTop1/* /2 + 1) */ && mouseY <= this.position.copy().y + /* round( */this.button_height/2 + yBallAdjustmentBot1/* /2-1) */) {
            
            this.button_over = true;
        } else if (!(this.button_type.equals("points") || this.button_type.equals("radius") || this.button_type.equals("chains") || this.button_type.equals("ball") || this.button_type.equals("duration")) &&
            mouseX >= this.position.copy().x - /* round( */this.button_width/ 2 - xAdjustmentLeft/* /2 + 1) */ && mouseX <= this.position.copy().x + /* round( */this.button_width/2 - xAdjustmentRight/* /2-1) */ &&
            mouseY >= this.position.copy().y - /* round( */ this.button_height/2 /* /2 + 1) */ && mouseY <= this.position.copy().y + /* round( */this.button_height/2 - yGenAdjustmentBot/* /2-1) */) {
            // cursor is inside the button
            this.button_over = true;
        } else {
            // cursor is outside the button
            this.button_over = false;
        }
        if (this.button_over && mousePressed && (millis() - startTime > button_time)) {
            // user clicks the button
            this.button_clicked = !this.button_clicked;
            // introduce timing so that the boolean won't be changing too often
            startTime = millis();
        }
    }
    // this will display the button in accordance to the parameters
    public void display() {
        rectMode(CENTER);
        if (this.button_over) {
            // inside the button
            if (button_type.equals("confirmation")) {
                fill(126, 244, 70);
            } else if (button_type.equals("skip")) {
                fill(255,0,0,200);
            } else {
                fill(0,0,255,100);
            }
        } else {
            // outside the button
            if (button_type.equals("confirmation")) {
                fill(169, 244, 134);
            } else if (button_type.equals("skip")) {
                fill(255,0,0,150);
            } else {
                fill(158,172,229);
            }
        }

        if (this.button_clicked) {
            // mouse clicked this button, blue stroke will be shown around the button
            stroke(0,0,255);
            strokeWeight(10);
        } else {
            // mouse did not clicked this button, normal black stroke surrounding the button
            stroke(0);
            strokeWeight(1);
        }
        
        // rectangle for the button
        rect(this.position.copy().x, this.position.copy().y, this.button_width, this.button_height);
        fill(0);

        // text for the button
        textAlign(CENTER, CENTER);
        textSize(13);
        text(this.button_text, this.position.copy().x, this.position.copy().y);

        // strokeWeight(30);  // Thicker
        // point(position.copy().x, position.copy().y);
        // strokeWeight(1);
        strokeWeight(1);
        stroke(0);
    }

    // add the number of balls/ upgrade percentage to the respective fields
    public void applyChanges() {
        // checks the upgrade type of the button
        if (this.button_type.equals("points")) {
            // points upgrade (nf is used for correcting to 2 decimal places)
            if (this.button_element.equals("electricity")) {
                shockMultiplier = shockMultiplier + (this.button_amount);
                println("shockMultiplier:" + shockMultiplier);
                return;
            } else if (this.button_element.equals("fire")) {
                // fire points * 1.xx
                fireMultiplier = fireMultiplier + (this.button_amount);
                println("fireMultiplier: "+fireMultiplier);
                return;
            } else if (this.button_element.equals("ice")) {
                // ice points * 1.xx
                frozenMultiplier = frozenMultiplier + (this.button_amount);
                println("frozenMultiplier: "+frozenMultiplier);
                return;
            } else if (this.button_element.equals("gravity")) {
                // gravity points * 1.xx
                gravityMultiplier = gravityMultiplier + (this.button_amount);
                println("gravityMultipler: "+gravityMultiplier);
                return;
            }
        } else if (this.button_type.equals("radius")) {
            // radius upgrade
            if (this.button_element.equals("fire")) {
                // fire radius * 1.xx
                fireRadius = fireRadius + this.button_amount;
                println("fireRadius: "+fireRadius);
                return;
            } else if (this.button_element.equals("gravity")) {
                // gravity radius * 1.xx
                gravityRadius = gravityRadius + this.button_amount;
                println("gravityRadius: "+gravityRadius);
                return;
            }
        } else if (this.button_type.equals("chains")) {
            if (this.button_element.equals("electricity")) {
                shockChains = shockChains + (int) this.button_amount;
                println("shockChains: "+shockChains);
                return;
            }
        } else if (this.button_type.equals("duration")) {
            if (this.button_element.equals("ice")) {
                freezeDuration = freezeDuration + (int) this.button_amount;
                println("freezeDuration: "+freezeDuration);
                return;
            }
        } else if (this.button_type.equals("ball")) {
            // add ball
            if (this.button_element.equals("electricity")) {
                inventory.addBall("shock");
                // electricity ball + number of balls to add
                return;
            } else if (this.button_element.equals("fire")) {
                inventory.addBall("fire");
                // fire ball + number of balls to add
                return;
            } else if (this.button_element.equals("ice")) {
                inventory.addBall("ice");
                // ice ball + number of balls to add
                return;
            } else if (this.button_element.equals("gravity")) {
                inventory.addBall("gravity");
               // gravity ball + number of balls to add
               return;
            }
        }
    }

}
