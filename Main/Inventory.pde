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
    addItem("fire", 0);
    //items.get(1).unlock();
    numBalls ++;
    addItem("shock",0);
    //items.get(2).unlock();
    numBalls ++;
    addItem("ice", 0);
    //items.get(3).unlock();
    numBalls ++;
    addItem("gravity", 0);
    //items.get(4).unlock();
    numBalls ++;
  }
  
  // add a ball to the inventory
  private void addItem(String colour, int count) {
    float y1 = calcHeight();
    Ball ball = new Ball(position.x, y1, ball_diameter*2.5, cue_ball_mass, colour);
    if (colour.equals("fire")) {
      items.add(new FireItem(position.x, y1, ball, count));
    } else if (colour.equals("shock")) {
      items.add(new ShockItem(position.x, y1, ball, count));
    } else if (colour.equals("ice")) {
      items.add(new IceItem(position.x, y1, ball, count));
    } else if (colour.equals("gravity")) {
      items.add(new GravityItem(position.x, y1, ball, count));
    }else {
      items.add(new InvItem(position.x, y1, ball, count));
    }
  }

  // Add ball to existing item
  public void addBall(String type) {
    for (InvItem i : items) {
      if (type == "fire") {
        if (i instanceof FireItem) {
          i.unlock();
          i.max += 1;
          i.count = i.max;
        }
      }
      if (type == "shock") {
        if (i instanceof ShockItem) {
          i.unlock();
          i.max += 1;
          i.count = i.max;
        }
      }
      if (type == "ice") {
        if (i instanceof IceItem) {
          i.unlock();
          i.max += 1;
          i.count = i.max;
        }
      }
      if (type == "gravity") {
        if (i instanceof GravityItem) {
          i.unlock();
          i.max += 1;
          i.count = i.max;
        }
      }
    }
  }
  
  // calculate the y location an inventory item should display at based on the number of balls already stored
  // fills top down
  public float calcHeight() {
    return position.y - (9-(numBalls*3))*height/17;
  }
  
  public void draw() {
    fill(255, 0, 0, 150);
    rect(position.x, position.y, width, height, 5);
    fill(0);
    textSize(20);
    textAlign(CENTER);
    text("Inventory", position.x, position.y - 9*height/20);
    for (InvItem item : items) {
      item.draw();
    }
    for (InvItem item : items) {
      if (item.hovered()) {
        if (item instanceof FireItem) {
          Tooltip tooltip = new Tooltip(new PVector(mouseX, mouseY), "fire");
          tooltip.draw();
        }
        else if (item instanceof ShockItem) {
          Tooltip tooltip = new Tooltip(new PVector(mouseX, mouseY), "shock");
          tooltip.draw();
        }
        else if (item instanceof IceItem) {
          Tooltip tooltip = new Tooltip(new PVector(mouseX, mouseY), "ice");
          tooltip.draw();
        }
        else if (item instanceof GravityItem) {
          Tooltip tooltip = new Tooltip(new PVector(mouseX, mouseY), "gravity");
          tooltip.draw();
        } else {
          Tooltip tooltip = new Tooltip(new PVector(mouseX, mouseY), "regular");
          tooltip.draw();
        }
      }
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

  // Get total number of balls for the shots remaining counter
  public int getBallCount() {
    int num = 0;
    for (InvItem i : items) {
      if (!i.locked) num += i.count;
    }
    return num;
  }

  // Reset the inventory for a game restart
  public void resetBalls() {
    for (InvItem i : items) {
      i.deselect();
      if (i.max > 0) {
        i.unlock();
      }
      i.count = i.max;
      println(i.max);
    }
    items.get(0).select();
    selected = items.get(0);
  }
}
