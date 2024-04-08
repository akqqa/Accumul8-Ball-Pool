import java.util.ArrayList;

int screen_width = 1280;
int screen_height = 720;
PoolTable table;


public void settings() {
  size(screen_width, screen_height);
}

public void setup() {
  table = new PoolTable(7, 300, new PVector(screen_width/2,screen_height/2));
}

void draw() {  // draw() loops forever, until stopped
  background(204);
  table.draw();
}
