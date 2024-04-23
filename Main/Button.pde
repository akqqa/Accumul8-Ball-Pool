public class Button {
    protected PVector position;
    protected float button_width;
    protected float button_height;
    protected int button_amount;
    protected String button_element;
    protected String button_type;
    protected String button_text;
    protected color button_color;
    protected boolean button_clicked;
    protected boolean button_over;
    protected int startTime = 0;

    // button constructor, taking in x, y coordinates, width, height, amount (for upgrade or ball addition), element, type(points, radius, upgrade or confirmation)
    public Button (float _x, float _y, float _width, float _height, int _amount, String _element, String _type/* , int _r, int _g, int _b */) {
        this.position = new PVector(_x, _y);
        this.button_width = _width;
        this.button_height = _height;
        this.button_amount = _amount;
        this.button_element = _element;
        this.button_type = _type;
        // this.button_color = color(_r, _g, _b);

        // check the type of the button and set the text accoerdingly
        if (this.button_type.equals("points") || this.button_type.equals("radius")) {
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

    // update function checks if the cursor is over the button and if the user clicks
    public void update() {
        if (mouseX >= this.position.copy().x - /* round( */this.button_width/ 2 - 10/* /2 + 1) */ && mouseX <= this.position.copy().x + /* round( */this.button_width/2 -10/* /2-1) */ &&
            mouseY >= this.position.copy().y - /* round( */this.button_height/2 + 15/* /2 + 1) */ && mouseY <= this.position.copy().y + /* round( */this.button_height/* /2-1) */) {
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
            fill(153);
        } else {
            // outside the button
            fill(255);
        }

        if (this.button_clicked) {
            // mouse clicked this button, blue stroke will be shown around the button
            stroke(0, 0, 255);
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
    }

    // add the number of balls/ upgrade percentage to the respective fields
    public void applyChanges() {
        // checks the upgrade type of the button
        if (this.button_type.equals("points")) {
            // points upgrade (nf is used for correcting to 2 decimal places)
            if (this.button_element.equals("electricity")) {
                // electricity points * 1.xx
                shockMultiplier = shockMultiplier + (this.button_amount/100.0);
                print(shockMultiplier);
                electricity_points = float(nf(electricity_points, 0, 2));
                
                println("electricity_points: "+electricity_points);
              
                return;
            } else if (this.button_element.equals("fire")) {
                // fire points * 1.xx
                fireMultiplier = fireMultiplier + (this.button_amount/ 100.0);
                fire_points = float(nf(fire_points, 0, 2));
                println("fire_points: "+fire_points);
                return;
            } else if (this.button_element.equals("ice")) {
                // ice points * 1.xx
                frozenMultiplier = frozenMultiplier + (this.button_amount/100.0);
                ice_points = float(nf(ice_points, 0, 2));
                println("ice_points: "+ice_points);
                return;
            }
            // } else if (this.button_element.equals("gravity")) {
            //     // gravity points * 1.xx
            //     gravity_points = gravity_points * (1 + this.button_amount/100.0);
            //     gravity_points = float(nf(gravity_points, 0, 2));
            //     println("gravity_points: "+gravity_points);
            //     return;
            // }
        } else if (this.button_type.equals("radius")) {
            // radius upgrade
            if (this.button_element.equals("electricity")) {
                // electricity radius * 1.xx
                shockRadius = shockRadius + (originalShockRadius * (button_amount/100.0));
                electricity_radius = float(nf(electricity_radius, 0, 2));
                println("electricity_radius: "+electricity_radius);
                return;
            } else if (this.button_element.equals("fire")) {
                // fire radius * 1.xx
                fireRadius = fireRadius + (originalFireRadius * (button_amount/100.0));
                fire_radius = float(nf(fire_radius, 0, 2));
                println("fire_radius: "+fire_radius);
                return;
            }
            // } else if (this.button_element.equals("ice")) {
            //     // ice radius * 1.xx
            //     ice_radius = ice_radius * (1 + button_amount/100.0);
            //     ice_radius = float(nf(ice_radius, 0, 2));
            //     println("ice_radius: "+ice_radius);
            //     return;
            // } else if (this.button_element.equals("gravity")) {
            //     // gravity radius * 1.xx
            //     gravity_radius = gravity_radius * (1 + button_amount/100.0);
            //     gravity_radius = float(nf(gravity_radius, 0, 2));
            //     println("gravity_radius: "+gravity_radius);
            //     return;
            // }
        } else if (this.button_type.equals("ball")) {
            // add ball
            if (this.button_element.equals("electricity")) {
                inventory.addBall("shock");
                // electricity ball + number of balls to add
                num_of_electricity_ball += this.button_amount;
                println("num_of_electricity_ball: "+num_of_electricity_ball);
                return;
            } else if (this.button_element.equals("fire")) {
                inventory.addBall("fire");
                // fire ball + number of balls to add
                num_of_fire_ball += this.button_amount;
                println("num_of_fire_ball: "+num_of_fire_ball);
                return;
            } else if (this.button_element.equals("ice")) {
                inventory.addBall("ice");
                // ice ball + number of balls to add
                num_of_ice_ball += this.button_amount;
                println("num_of_ice_ball: "+num_of_ice_ball);
                return;
            }
            // } else if (this.button_element.equals("gravity")) {
            //     // gravity ball + number of balls to add
            //     num_of_gravity_ball += this.button_amount;
            //     println("num_of_gravity_ball: "+num_of_gravity_ball);
            //     return;
            // }
        }
    }

}
