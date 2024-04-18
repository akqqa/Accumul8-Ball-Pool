public class Menu {
    PVector position;
    float menu_width;
    float menu_height;
    String menu_title = "Upgrade Menu";
    public Menu (float _x, float _y, float _width, float _height) {
        position = new PVector(_x, _y);
        this.menu_width = _width;
        this.menu_height = _height;
    }
    public void display() {
        rectMode(CENTER);
        fill(255);
        rect(this.position.copy().x, this.position.copy().y, this.menu_width, this.menu_height);
        textAlign(CENTER, CENTER);
        textSize(20);
        fill(0);
        text(this.menu_title, this.position.copy().x, this.position.copy().y - this.menu_height/2 + 50);
    }
}
