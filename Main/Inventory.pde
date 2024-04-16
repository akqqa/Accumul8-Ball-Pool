public class Inventory {
  
  protected PVector position;
  protected float height, width;
  float numBalls = 1;
  InvItem selected;
  
  // stores all inventory items, by nature of order, item 0 is the cue ball
  ArrayList<InvItem> items = new ArrayList<>();

  public Inventory(float x, float y, float width, float height, int init_shots) {
    // init_shots are the number of shots that are attributed to the standard white cue ball
    this.position = new PVector(x, y);
    this.height = height;
    this.width = width;
    initInv(init_shots);   
  }
  
  // Function to initialise the inventory
  // Items default locked and deselected
  private void initInv(int init_shots) {
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
  
  // add a ball to the inventory
  private void addItem(String colour, int count) {
    float y1 = calcHeight();
    Ball ball = new Ball(position.x, y1, ball_diameter*2, ball_mass+0.5, colour);
    items.add(new InvItem(position.x, y1, ball, count));
  }
  
  // calculate the y location an inventory item should display at based on the number of balls already stored
  // fills top down
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
  
  // Function to determine if the mouse is within the inventory 
  public boolean mouseInInventory() {
    if ( mouseX > position.x - width/2 && mouseX < position.x + width/2 &&
         mouseY > position.y - height/2 && mouseY < position.y + height/2) return true;
    return false;
  }
  
  // Function to select an item (called when mouse is within the inventory)
  public void selectItem() {
    boolean res;
    for (InvItem item : items) {
      
      // ignore item if it is locked (cannot be selected)
      if (item.locked) continue;
      
      res = item.hovered();
      // if mouse is over item
      if (res) {
        selected.deselect();  // deselect currently selected
        item.select();        // select current item
        selected = item;      // change which is stored as selected
        break;
      }
    }
  }
  
  public color selectedBallType() {
    return selected.ball.colour;
  }
  
  // Function to affect counters and selected/locked status when using balls
  public void useSelected() {
    // decrement ball counter
    selected.count --;
    
    // if no balls left for that type...
    if (selected.count == 0) {
      print("no balls left");
      
      // deselect and lock it
      selected.deselect();
      selected.lock();
      
      // select the first available type, if none - set to null
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

  public int getBallCount() {
    int num = 0;
    for (InvItem i : items) {
      num += i.count;
    }
    return num;
  }

  public void resetBalls() {
    for (InvItem i : items) {
      i.deselect();
      if (i.max > 0) {
        i.unlock();
      }
      i.count = i.max;
    }
    items.get(0).select();
    selected = items.get(0);
  }
}
