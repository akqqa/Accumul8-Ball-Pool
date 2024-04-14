import java.util.Collections;

final class PoolTable {
  public int sides;
  public float scale;
  public PVector position;
  protected float interior_angle;
  protected ArrayList<Line> lines = new ArrayList<Line>();
  protected ArrayList<Pocket> pockets = new ArrayList<Pocket>();
  protected PShape shape;
  protected float elasticity = 0.5;
  
  public PoolTable(int sides, float scale, PVector position, float maxX) {
    this.sides = sides;
    this.scale = scale;
    this.position = position.copy();
    this.interior_angle = ((sides-2) * 180) / sides;
    this.shape = polygon(this.position.x, this.position.y, this.scale, this.sides, (this.interior_angle/2*PI)/180); // Rotate by half the size of the interior angle of the shape being drawn to make it upright  
    this.shape = scaleShape(this.position.x, this.position.y, this.shape, maxX);
    
    // Create list of lines for collisions
    for (int i = 0; i < this.shape.getVertexCount() - 1; i++) {
      PVector start = this.shape.getVertex(i).copy();
      PVector end = this.shape.getVertex(i+1).copy();
      lines.add(new Line(start, end));
    }
    // Add final line connecting last and first vertex
    PVector start = this.shape.getVertex(this.shape.getVertexCount() - 1);
    PVector end = this.shape.getVertex(0);
    lines.add(new Line(start, end));
    spawnPockets();
  }
  
  void draw() {
    shape(this.shape);
    for (Line line : this.lines) {
      stroke(200,0,0);
      strokeWeight(5);
      line(line.start.x, line.start.y, line.end.x, line.end.y);
    }
    for (Pocket p : pockets) {
      p.draw();
    }
  }
  
  void spawnPockets() {
    for (Line l : lines) {
      // corners
      pockets.add(new Pocket(l.start.x, l.start.y, pocket_diameter*1.5));
      // lines
      pockets.add(new Pocket((l.start.x + l.end.x)/2, (l.start.y + l.end.y)/2, pocket_diameter));
    }
  }
  
  // void update() {
  //   // Detect collisions for each line (with a circle around the mouse for now)
  //   for (Line line : this.lines) {
  //     if (lineCircle(line.start.x, line.start.y, line.end.x, line.end.y, mouseX, mouseY, 1)) {
  //       stroke(0,200,0);
  //       strokeWeight(5);
  //       line(line.start.x, line.start.y, line.end.x, line.end.y);
  //     }
  //   }
  // }

  // Check if ball is colliding with a wall. If so, reflect the velocity of the ball based on the wall angle
  // Projects backwards based on the current velocity of the ball, with a step size of the balls diameter
  void boundaryCollision(Ball b) {
    // Create a list of all ball positions between the current position and the previous position based on the velocity, with a step size of diameter
    PVector currentPosition = b.position.copy();
    ArrayList<PVector> pastPositions = new ArrayList<PVector>();
    pastPositions.add(currentPosition);
    // Get each position between current and next position with a step size of radius
    if (b.velocity.mag() > b.radius) {
      int iterations = (int) ((int)b.velocity.mag() / b.radius);
      for (int i = 1; i <= iterations; i++) {
        print("e");
        pastPositions.add(b.position.copy().sub(b.velocity.copy().setMag(b.radius*i)));
      }
    }
    pastPositions.add(b.position.copy().sub(b.velocity));
    for (PVector pos : pastPositions) {
      //print("hi");
      circle(pos.x, pos.y, 2);
    }

    Collections.reverse(pastPositions); // Reverse so calculates in chronological order

    for (PVector pos : pastPositions) {
      boolean collided = false;
      for (Line line : this.lines) {
        if (lineCircle(line.start.x, line.start.y, line.end.x, line.end.y, pos.x, pos.y, b.radius)) {
          collided = true;
          println("colliding");
          // Calculate normal of line - https://stackoverflow.com/a/1243676
          PVector normalVector = new PVector((line.end.y-line.start.y), -(line.end.x-line.start.x));
          print("normal");
          println(normalVector);
          // Calculate components of balls velocity perpendicular and parallel to the line colliding with
          // https://stackoverflow.com/a/573206
          PVector u = normalVector.mult((b.velocity.copy().dot(normalVector) / normalVector.dot(normalVector)));
          PVector w = b.velocity.copy().sub(u);

          PVector newVelocity = w.sub(u.mult(elasticity));
          b.velocity = newVelocity.copy();
          print("new velocity");
          println(b.velocity);

          // Like with ball collisions, move ball away from the intersection between it and the wall (to prevent phasing?)
          // Using lineCircle() logic, calculate vector between center of circle and line
          PVector intersect = lineCircleVector(line.start.x, line.start.y, line.end.x, line.end.y, pos.x, pos.y, b.radius);
          // move the position of the ball away from the wall in the direction of the intersect, with a magnitude of the radius - the intersects magnitude
          if (intersect != null) {
            if (centreInsideTable(position.x, position.y, intersect.x+pos.x, intersect.y+pos.y, pos.x, pos.y))
              b.position = pos.sub(intersect.setMag(b.radius-intersect.mag() + 1)); // +1 as a small offset to prevent getting stuck in walls
            // else do with radius added to the above
            else {
              print("change");
              println(intersect.setMag(-b.radius-intersect.mag() - 1)); // -1 as a small offset to prevent getting stuck in walls
              b.position = pos.sub(intersect);
            }
            print("intersect");
            println(intersect);
            println();
          }
        }
      }
      if (collided) { // If this past version of the ball hit a wall, return as no need to handle further collisions of further ball versins
        return;
      }
    }
  }
  boolean ballInPocket(Ball b) {
    for (Pocket p : pockets) {
     if (p.pocketed(b)) {
       //b.velocity.setMag(p.position.copy().sub(b.position).mult(0.1).mag());
       b.velocity = p.position.copy().sub(b.position).mult(0.05);
       b.acceleration = new PVector(0, 0);
       return true;
     }
    }
    return false;
  }
  boolean ballFinished(Ball b) {
    if (b.pocket_counter++ == 20) return true;
    return false;
  }
}

// Adapted from https://processing.org/examples/regularpolygon.html
PShape polygon(float x, float y, float radius, int sides, float initial_angle) {
  float angle = TWO_PI / sides;
  PShape s = createShape();
  s.beginShape();
  for (float a = initial_angle; a < TWO_PI + initial_angle; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    s.vertex(sx, sy);
  }
  s.fill(58, 181, 3);
  s.endShape(CLOSE);
  return s;
}

PShape scaleShape(float x, float y, PShape shape, float maxX) {
  float maxDist = 0;
  for (int i = 0; i < shape.getVertexCount(); i++) {
     if (abs(shape.getVertex(i).x - x) > maxDist) {
       maxDist = abs(shape.getVertex(i).x - x);
     }
  }
  if (maxDist < maxX) {
    return shape;
  }
  
  float scaleFactor = maxX/maxDist;
  for (int i = 0; i < shape.getVertexCount(); i++) {
     // Scale each x by the scale factor
     float xDist = shape.getVertex(i).x - x;
     xDist = xDist * scaleFactor;
     shape.setVertex(i, x+xDist, shape.getVertex(i).y);
  }
  
  return shape;
}
