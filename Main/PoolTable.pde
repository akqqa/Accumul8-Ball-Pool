import java.util.Collections;

final class PoolTable {
  public int sides;
  public float scale;
  public PVector position;
  protected float interior_angle;
  protected ArrayList<Line> lines = new ArrayList<Line>();
  protected ArrayList<Pocket> pockets = new ArrayList<Pocket>();
  protected PShape shape;
  protected PShape boundary;
  public float elasticity = 0.5;
  
  public PoolTable(int sides, float scale, PVector position, float maxX) {
    this.sides = sides;
    this.scale = scale;
    this.position = position.copy();
    this.interior_angle = ((sides-2) * 180) / sides;
    this.shape = polygon(this.position.x, this.position.y, this.scale, this.sides, (this.interior_angle/2*PI)/180); // Rotate by half the size of the interior angle of the shape being drawn to make it upright  
    this.shape = scaleShape(this.position.x, this.position.y, this.shape, maxX);
    float scaleFactor = 1;
    if (this.sides == 4) {
      scaleFactor = 1.3;
    }
    this.boundary = polygon(this.position.x, this.position.y, this.scale + (pocket_diameter * scaleFactor), this.sides, (this.interior_angle/2*PI)/180);
    this.boundary = scaleShape(this.position.x, this.position.y, this.boundary, maxX + (pocket_diameter));
    this.boundary.setFill(color(139,69,19));
    
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
    // Draw boundary first
    shape(this.boundary);
    shape(this.shape);
    for (Line line : this.lines) {
      stroke(0,0,0);
      strokeWeight(1);
      line(line.start.x, line.start.y, line.end.x, line.end.y);
    }
    for (Pocket p : pockets) {
      p.draw();
    }
  }
  
  // Spawn the pockets on the table
  void spawnPockets() {
    int count = 0;
    int pocket_num = 0;
    for (Line l : lines) {
      if (sides == 4) {
        // corners
        pockets.add(new Pocket(l.start.x, l.start.y, pocket_diameter*1.5));
        // lines
        if (count++ % 2 == 1)
          pockets.add(new Pocket((l.start.x + l.end.x)/2, (l.start.y + l.end.y)/2, pocket_diameter*1.2));
      } else if (sides < 7) {
        pockets.add(new Pocket(l.start.x, l.start.y, pocket_diameter*1.5));
      } else {
        // even sided
        if (sides % 2 == 0) {
          if ((((count - (3 + (sides/3)*pocket_num) == 0) && pocket_num < 3) ||
                ((count - (sides + 1 + (sides/3)*(pocket_num-2)) == 0) && pocket_num > 2)) && count < sides*2) {
            println(count, (sides + 1 + (sides/3)*(pocket_num-2)));
            pockets.add(new Pocket(l.start.x, l.start.y, pocket_diameter*1.5));
            pocket_num ++;
          }
          count ++;
          if ((((count - (3 + (sides/3)*pocket_num) == 0) && pocket_num < 3) ||
                ((count - (sides + 1 + (sides/3)*(pocket_num-2)) == 0) && pocket_num > 2)) && count < sides*2) {
            println(count, (sides + 1 + (sides/3)*(pocket_num-2)));
            pockets.add(new Pocket((l.start.x + l.end.x)/2, (l.start.y + l.end.y)/2, pocket_diameter*1.2));
            pocket_num ++;
          }
          count ++; 
        }
        // odd sided
        else {
          if (count != sides + 1 && count >= (sides-7)*2) pockets.add(new Pocket(l.start.x, l.start.y, pocket_diameter*1.5));
          count += 2;
        }

      }
    }
  }

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
        pastPositions.add(b.position.copy().sub(b.velocity.copy().setMag(b.radius*i)));
      }
    }
    pastPositions.add(b.position.copy().sub(b.velocity));
    for (PVector pos : pastPositions) {
      //print("hi");
    }

    Collections.reverse(pastPositions); // Reverse so calculates in chronological order

    for (PVector pos : pastPositions) {
      boolean collided = false;
      for (Line line : this.lines) {
        if (lineCircle(line.start.x, line.start.y, line.end.x, line.end.y, pos.x, pos.y, b.radius)) {
          wallHit.trigger();
          collided = true;
          // Calculate normal of line - https://stackoverflow.com/a/1243676
          PVector normalVector = new PVector((line.end.y-line.start.y), -(line.end.x-line.start.x));
          // Calculate components of balls velocity perpendicular and parallel to the line colliding with
          // https://stackoverflow.com/a/573206
          PVector u = normalVector.mult((b.velocity.copy().dot(normalVector) / normalVector.dot(normalVector)));
          PVector w = b.velocity.copy().sub(u);

          PVector newVelocity = w.sub(u.mult(elasticity));
          b.velocity = newVelocity.copy();

          // Like with ball collisions, move ball away from the intersection between it and the wall (to prevent phasing?)
          // Using lineCircle() logic, calculate vector between center of circle and line
          PVector intersect = lineCircleVector(line.start.x, line.start.y, line.end.x, line.end.y, pos.x, pos.y, b.radius);
          // move the position of the ball away from the wall in the direction of the intersect, with a magnitude of the radius - the intersects magnitude
          if (intersect != null) {
            if (centreInsideTable(position.x, position.y, intersect.x+pos.x, intersect.y+pos.y, pos.x, pos.y))
              b.position = pos.sub(intersect.setMag(b.radius-intersect.mag() + 1)); // +1 as a small offset to prevent getting stuck in walls
            // else do with radius added to the above
            else {
              b.position = pos.sub(intersect);
            }
          }
        }
      }
      if (collided) { // If this past version of the ball hit a wall, return as no need to handle further collisions of further ball versins
        return;
      }
    }
  }

  // Check if ball is in pocket, and if so move into pocket
  boolean ballInPocket(Ball b) {
    for (Pocket p : pockets) {
     if (p.pocketed(b)) {
       b.velocity = p.position.copy().sub(b.position).mult(0.05);
       if (b.velocity.mag() < 0.1) {
        b.velocity.setMag(0);
       }
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
// Create a regular polygon
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

// Scale shape on the x-axis to squash it 
PShape scaleShape(float x, float y, PShape shape, float maxX) {
  float maxDist = 0;
  // Figure out the furthest horizontal distance that a vertex is
  for (int i = 0; i < shape.getVertexCount(); i++) {
     if (abs(shape.getVertex(i).x - x) > maxDist) {
       maxDist = abs(shape.getVertex(i).x - x);
     }
  }
  if (maxDist < maxX) {
    return shape;
  }
  
  // Scale the entire shape by the maximum horizontal distance to ensure it is within a set boundary
  float scaleFactor = maxX/maxDist;
  for (int i = 0; i < shape.getVertexCount(); i++) {
     // Scale each x by the scale factor
     float xDist = shape.getVertex(i).x - x;
     xDist = xDist * scaleFactor;
     shape.setVertex(i, x+xDist, shape.getVertex(i).y);
  }
  
  return shape;
}
