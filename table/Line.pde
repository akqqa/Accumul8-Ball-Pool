final class Line {
  public PVector start;
  public PVector end;
  
  public Line(PVector start, PVector end) {
    this.start = start.copy();
    this.end = end.copy();
  }

}
