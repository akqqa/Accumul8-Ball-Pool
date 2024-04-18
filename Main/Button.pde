public class Button {
    protected PVector position;
    protected float button_width;
    protected float button_height;
    protected int button_amount;
    protected String button_element;
    protected String button_type;
    protected String button_text;
    protected boolean button_clicked;
    protected boolean button_over;
    public Button (float _x, float _y, float _width, float _height, int _amount, String _element, String _type, int r, int g, int b) {
        this.position = new PVector(_x, _y);
        this.button_width = _width;
        this.button_height = _height;
        this.button_amount = _amount;
        this.button_element = _element;
        this.button_type = _type;
        if (this.button_type.equals("points") || this.button_type.equals("radius")) {
            this.button_text = "+" + button_amount + "% " + this.button_element + " " + this.button_type;
        } else if (this.button_type.equals("ball")) {
            this.button_text = "+" + button_amount + " " + this.button_element + " "+ this.button_type;
        } else {
            this.button_text = "Confirm";
        }
        

        this.button_clicked = false;
        this.button_over = false;
    }

    public void update() {
        if (mouseX >= this.position.copy().x - /* round( */this.button_width/ 2 - 10/* /2 + 1) */ && mouseX <= this.position.copy().x + /* round( */this.button_width/2 -10/* /2-1) */ &&
            mouseY >= this.position.copy().y - /* round( */this.button_height/2 + 15/* /2 + 1) */ && mouseY <= this.position.copy().y + /* round( */this.button_height/* /2-1) */) {
            this.button_over = true;
        } else {
            this.button_over = false;
        }
        if (this.button_over && mousePressed) {
            this.button_clicked = true;
        }
    }
    public void display() {
        rectMode(CENTER);
        if (this.button_over) {
            // inside the button
            fill(153);
        } else {
            fill(255);
        }

        if (this.button_clicked) {
            stroke(0, 0, 255);
            strokeWeight(10);
        } else {
            stroke(0);
            strokeWeight(1);
        }
        
        rect(this.position.copy().x, this.position.copy().y, this.button_width, this.button_height);
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(20);
        text(this.button_text, this.position.copy().x, this.position.copy().y);
    }

    // add the number of balls/ upgrade percentage to the respective fields
    public void applyChanges() {}

}
