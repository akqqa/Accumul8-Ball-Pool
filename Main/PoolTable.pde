final class PoolTable {
  public int sides;
  public float scale;
  public PVector position;
  protected float interior_angle;
  protected ArrayList<Line> lines = new ArrayList<Line>();
  protected PShape shape;
  protected float elasticity = 1;
  
  public PoolTable(int sides, float scale, PVector position) {
    this.sides = sides;
    this.scale = scale;
    this.position = position.copy();
    this.interior_angle = ((sides-2) * 180) / sides;
    this.shape = polygon(this.position.x, this.position.y, this.scale, this.sides, (this.interior_angle/2*PI)/180); // Rotate by half the size of the interior angle of the shape being drawn to make it upright    
    
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
  }
  
  void draw() {
    shape(this.shape);
    for (Line line : this.lines) {
      stroke(200,0,0);
      strokeWeight(5);
      line(line.start.x, line.start.y, line.end.x, line.end.y);
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
  void boundaryCollision(Ball b) {
    for (Line line : this.lines) {
      if (lineCircle(line.start.x, line.start.y, line.end.x, line.end.y, b.position.x, b.position.y, b.radius)) {
        print("colliding");
        // Calculate normal of line - https://stackoverflow.com/a/1243676
        PVector normalVector = new PVector((line.end.y-line.start.y), -(line.end.x-line.start.x));
        // Calculate components of balls velocity perpendicular and parallel to the line colliding with
        // https://stackoverflow.com/a/573206
        PVector u = normalVector.mult((b.velocity.copy().dot(normalVector) / normalVector.dot(normalVector)));
        PVector w = b.velocity.copy().sub(u);

        PVector newVelocity = w.sub(u.mult(elasticity));
        b.velocity = newVelocity.copy();

        // Like with ball collisions, move ball away from the intersection between it and the wall (to prevent phasing?)
      }
    }
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
  s.endShape(CLOSE);
  return s;
}
