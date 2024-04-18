public class Button {
    PVector position;
    float width;
    float height;
    String text;
    public Button (float _x, float _y, float _width, float _height, String _text, int r, int g, int b) {
        this.position = new PVector(_x, _y);
        this.width = _width;
        this.height = _height;
        this.text = _text;
    }

    public void display() {
        rectMode(CENTER);
        fill(255);
        rect(this.position.copy().x, this.position.copy().y, this.width, this.height);
        fill(0);
        textAlign(CENTER, CENTER);
        text(this.text, this.position.copy().x, this.position.copy().y);
    }

}
