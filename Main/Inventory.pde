public class Inventory {
  
  protected PVector position;
  protected float height, width;
  float numBalls = 1;
  InvItem selected;
  
  ArrayList<InvItem> items = new ArrayList<>();
  //ArrayList<Integer> counts = new ArrayList<>();

  public Inventory(float x, float y, float width, float height, int init_shots) {
    this.position = new PVector(x, y);
    this.height = height;
    this.width = width;

    addItem("white", init_shots);
    items.get(0).select();
    selected = items.get(0);
    items.get(0).unlock();
    numBalls ++;
    addItem("brown", 1);
    items.get(1).unlock();
    numBalls ++;
    addItem("blue", 1);
    items.get(2).unlock();
    numBalls ++;
    addItem("green", 0);
    numBalls ++;
    addItem("pink", 0);
    numBalls ++;
    addItem("yellow", 0);
  }
  
  private void addItem(String colour, int count) {
    float y1 = calcHeight();
    Ball ball = new Ball(position.x, y1, ball_diameter*2, ball_mass+0.5, colour);
    items.add(new InvItem(position.x, y1, ball, count));
  }
  
  public float calcHeight() {
    return position.y - (10-(numBalls*3))*height/20;
  }
  
  public void draw() {
    fill(200, 0, 0, 128);
    rect(position.x, position.y, width, height, 5);
    fill(0);
    text("Inventory", position.x, position.y - 9*height/20);
    for (InvItem item : items) {
      item.draw();
    }
  }
  
  public boolean mouseInInventory() {
    if ( mouseX > position.x - width/2 && mouseX < position.x + width/2 &&
         mouseY > position.y - height/2 && mouseY < position.y + height/2) return true;
    return false;
  }
  
  public void selectItem() {
    boolean res;
    for (InvItem item : items) {
      if (item.locked) continue;
      res = item.hovered();
      if (res) {
        selected.deselect();
        item.select();
        selected = item;
        break;
      }
    }
  }
  
  public color selectedBallType() {
    return selected.ball.colour;
  }
  
  public void useSelected() {
    selected.count --;
    if (selected.count == 0) {
      selected.deselect();
      selected.lock();
      for (InvItem item : items) {
        if (!item.locked) {
          // if there is a remaining item select it
          selected = item;
          item.select();
          return;
        }
      } selected = null;
    }
  }
}
