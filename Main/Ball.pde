
public class Ball {
  
    protected final float K1 = 0.0315, //https://billiards.colostate.edu/faq/physics/physical-properties/
                          K2 = 0.0;

    public PVector position;
    public PVector velocity;
    public PVector acceleration;
    //protected float invMass;
    public float diameter;
    public float radius;
    protected float mass;
    protected float normalMass;
    protected String colourString;
    protected color colour;
    public int effectDuration = 0;

    float elastic_constant = 0.9;
    
    public int pocket_counter = 0;

    // power booleans
    protected boolean onFire;
    protected boolean shocked;
    protected boolean frozen;
    protected boolean gravity;
    protected PVector pullVelocity = new PVector(0,0);
    protected boolean powerBall;

    protected ArrayList<Ball> hitThisShot = new ArrayList<Ball>();

    public Ball(float x, float y, float diameter, float mass, String colour) {
        this.position = new PVector(x, y);
        this.diameter = diameter;
        this.radius = diameter / 2;
        this.velocity = new PVector(0, 0);
        this.acceleration = new PVector(0, 0);
        //this.invMass = 1/mass;
        this.mass = mass;
        this.normalMass = mass;
        this.colourString = colour;
        colourSpecific(colour);
    }
    
    
    // ADD TO THIS FOR SCORING LATER
    protected void colourSpecific(String colour) {
      switch (colour) {
        case "white":
          this.colour = color(255,255,255);
          break;
        case "black":
          this.colour = color(0,0,0);
          break;
        case "red":
          this.colour = color(255, 0, 0);
          break;
        case "pink":
          this.colour = color(255,182,193);
          break;
        case "blue":
          this.colour = color(0, 0, 255);
          break;
        case "green":
          this.colour = color(0,255,0);
          break;
        case "yellow":
          this.colour = color(255,255,0);
          break;
        case "brown":
          this.colour = color(139,69,19);
          break;
        case "orange":
          this.colour = color(235, 146, 52);
          break;
        case "lightblue":
          this.colour = color(173,216,230);
          break;
      }
    }
    
    public void setColour(color colour) {
      this.colour = colour;
    }


    public void draw() {
      //text(mass, position.x, position.y);
      stroke(0,0,0);
      strokeWeight(1);
      fill(colour);     
      circle(position.x, position.y, diameter);
      power(255);
      // If shocked, draw raidius of shock
      // if (this.shocked) {
      //   noStroke();
      //   fill(255,255,0, 100);
      //   circle(position.x, position.y, shockRadius*2);
      // }
      //if (!this.powerBall) {
      //  println(this.mass);
      //}
      // If frozen, keep setting velocity to zero! hacky but to fix a bug
      if (this.frozen && !this.equals(cue_ball)) {
        this.velocity = new PVector(0,0);
      }
    }
    
    public void draw(float opacity) {
      stroke(0,0,0, opacity);
      strokeWeight(1);
      fill(colour, opacity);     
      circle(position.x, position.y, diameter);
      power(opacity);
    }
    
    protected void power(float opacity) {
      if (onFire) {
        imageMode(CENTER);
        image(flame, position.x, position.y, radius, radius * 1.75);
      }
      else if (shocked) {
        imageMode(CENTER);
        image(bolt, position.x, position.y, radius, radius * 1.75);
      }
      else if (frozen) {
        imageMode(CENTER);
        image(frost, position.x, position.y, radius*1.5, radius * 1.75);
      }
      else if (gravity) {
        imageMode(CENTER);
        image(grav_arrow, position.x, position.y-diameter*0.0625, radius*1.5, radius * 1.5);
      }
      
      
    }
    
    
    public void applyForce(PVector force) { 
      PVector f = PVector.mult(force, 1/mass);  // divide by the mass for a = f/m
      acceleration.add(f);                       // adding the different accelerations contains the forces
    }
    
    
    public void applyDrag() {
      PVector drag = velocity.copy();
      
      //Calculate the total drag coefficient
      float dragCoeff = drag.mag();
      dragCoeff = K1 * dragCoeff + K2 * dragCoeff * dragCoeff;
      
      //Calculate the final force and apply it
      drag.normalize();
      drag.mult(-dragCoeff);
      applyForce(drag);
    }
    
    
    // movement
    public void move() {
      //println(powerBall);
      if (!(frozen && !powerBall)) {
        velocity.add(acceleration);
        position.add(velocity);
        position.add(pullVelocity);
        pullVelocity.setMag(0);
      }
      acceleration.mult(0);
     
      // forces slow balls to stop
      if (velocity.mag() < 0.1) {
        velocity.setMag(0);
      }
    }
    
    
    // function to get polar coords
    public PVector polar(float radius, float angle){
      return new PVector(radius * cos(angle), radius * sin(angle));
    }
    
    
    //public void ballCollision(Ball other_ball) {  // collisions from https://openprocessing.org/sketch/560864
    //  // check they are colliding
    //  if(position.dist(other_ball.position) > diameter) return;
      
    //  // find angle of impact point
    //  float angle = position.copy().sub(other_ball.position).heading();
    //  position = other_ball.position.copy().add(this.polar(diameter, angle));
      
    //  // find accelerations to apply to balls
    //  float A1 = velocity.heading() - angle;
    //  float A2 = other_ball.velocity.heading() - angle;
      
    //  // convert to velocities
    //  PVector V1 = polar(velocity.mag()*cos(A1), angle);
    //  PVector V2 = polar(other_ball.velocity.mag()*cos(A2), angle);
      
    //  // apply impulses
    //  acceleration.sub(V1).add(V2);
    //  other_ball.acceleration.sub(V2).add(V1);
    //  //applyForce(new PVector(0, 0).sub(V1).add(V2));
    //  //other_ball.applyForce(new PVector(0, 0).sub(V2).add(V1));
    //}
    
    public boolean ballCollision(Ball other) {  // collisions fomr https://processing.org/examples/circlecollision.html
      // Create a list of all ball positions between the current position and the previous position based on the velocity, with a step size of diameter
      PVector currentPosition = this.position.copy();
      ArrayList<PVector> pastPositions = new ArrayList<PVector>();
      pastPositions.add(currentPosition);
      // Get each position between current and next position with a step size of radius
      int iterations = (int) ((int)this.velocity.mag() / 1);
      for (int i = 1; i <= iterations; i++) {
        pastPositions.add(this.position.copy().sub(this.velocity.copy().setMag(1*i)));
      }
      pastPositions.add(this.position.copy().sub(this.velocity));
      for (PVector pos : pastPositions) {
        //circle (pos.x, pos.y, 25);
      }

      Collections.reverse(pastPositions); // Reverse so calculates in chronological order

      for (PVector pos : pastPositions) {
        this.position = pos;
        //circle(this.position.x, this.position.y, 5);
  
        // Get distances between the balls components
        PVector distanceVect = PVector.sub(other.position, position);
    
        // Calculate magnitude of the vector separating the balls
        float distanceVectMag = distanceVect.mag();
    
        // Minimum distance before they are touching
        float minDistance = radius + other.radius;
    
        if (distanceVectMag < minDistance) {
          //circle(this.position.x, this.position.y, 25);
        
          ballHit.trigger();
            
          //If this ball is frozen, and soemthing hits it, add points and handle accordingly
          if (frozen && !powerBall) {
            if (firstFrameOfShot) { // HACK to prevent first round balls from adding extra ice points
              hitThisShot.add(other);
            } else if (!hitThisShot.contains(other) && (other.frozen == false || other.equals(cue_ball))) { // Ensures each ball can only score once when hitting - to prevent many collisions being overpowered
              score += points_per_ball * frozenMultiplier;
              animations.add(new PointIcon(other.position.copy(), 60, points_per_ball * frozenMultiplier));
              hitThisShot.add(other);
            }
          }
          // If the other ball is frozen, and this ball hits it, handle accordingly
          if (other.frozen && (!this.frozen || this.powerBall)) {
            if (firstFrameOfShot) { // HACK to prevent first round balls from adding extra ice points
              other.hitThisShot.add(this);
            } else if (!other.hitThisShot.contains(this)) { // Ensures each ball can only score once when hitting - to prevent many collisions being overpowered
              score += points_per_ball * frozenMultiplier;
              animations.add(new PointIcon(this.position.copy(), 60, points_per_ball * frozenMultiplier));
              other.hitThisShot.add(this);
            }
          }
          
          float distanceCorrection = ((minDistance-distanceVectMag) + 1)/2.0;
          PVector d = distanceVect.copy();
          PVector correctionVector = d.normalize().mult(distanceCorrection);

          // If other is frozen and this is not, move this twice as much
          // If this is frozen and other is not, move other twice as much
          // If neither frozen, move both by correction vector
          if (this.frozen && !this.equals(cue_ball) && (!other.frozen || other.powerBall)) {
            other.position.add(correctionVector.mult(2));
          } else if (other.frozen && !other.equals(cue_ball) && (!this.frozen || this.powerBall)) {
            this.position.sub(correctionVector.mult(2));
          }
          else {
            other.position.add(correctionVector);
            this.position.sub(correctionVector);
          }
    
          // get angle of distanceVect
          float theta  = distanceVect.heading();
          // precalculate trig values
          float sine = sin(theta);
          float cosine = cos(theta);
    
          /* bTemp will hold rotated ball positions. You 
          just need to worry about bTemp[1] position*/
          PVector[] bTemp = {
            new PVector(), new PVector()
          };
    
          /* this ball's position is relative to the other
          so you can use the vector between them (bVect) as the 
          reference point in the rotation expressions.
          bTemp[0].position.x and bTemp[0].position.y will initialize
          automatically to 0.0, which is what you want
          since b[1] will rotate around b[0] */
          bTemp[1].x  = cosine * distanceVect.x + sine * distanceVect.y;
          bTemp[1].y  = cosine * distanceVect.y - sine * distanceVect.x;
    
          // rotate Temporary velocities
          PVector[] vTemp = {
            new PVector(), new PVector()
          };
    
          vTemp[0].x = cosine * velocity.x + sine * velocity.y;
          vTemp[0].y = cosine * velocity.y - sine * velocity.x;
          vTemp[1].x = cosine * other.velocity.x + sine * other.velocity.y;
          vTemp[1].y = cosine * other.velocity.y - sine * other.velocity.x;
    
          /* Now that velocities are rotated, you can use 1D
          conservation of momentum equations to calculate 
          the final velocity along the x-axis. */
          PVector[] vFinal = {  
            new PVector(), new PVector()
          };
    
          // final rotated velocity for b[0]
          vFinal[0].x = ((mass - other.mass) * vTemp[0].x + 2 * other.mass * vTemp[1].x) / (mass + other.mass);
          vFinal[0].y = vTemp[0].y;
    
          // final rotated velocity for b[0]
          vFinal[1].x = ((other.mass - mass) * vTemp[1].x + 2 * mass * vTemp[0].x) / (mass + other.mass);
          vFinal[1].y = vTemp[1].y;
    
          // hack to avoid clumping
          bTemp[0].x += vFinal[0].x;
          bTemp[1].x += vFinal[1].x;
    
          /* Rotate ball positions and velocities back
          Reverse signs in trig expressions to rotate 
          in the opposite direction */
          // rotate balls
          PVector[] bFinal = { 
            new PVector(), new PVector()
          };
    
          bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
          bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
          bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
          bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;
    
          // ALL OF THIS WAS NOT ONLY UNNECCESARY BUT CAUSED THE BALLS TO PHASE THROUGH EACH OTHER (still happens now but less)

          // update balls to screen position
          //other.position.x = position.x + bFinal[1].x + 1;
          //other.position.y = position.y + bFinal[1].y + 1;
          
          // // Simply update balls to be apart from each other in direction of intersection
          // // intersection magnitude
          // if (!frozen) {
          //   float intersectMag = this.radius + other.radius - (distanceVect.mag());
          //   PVector scaledDistanceVect = distanceVect.copy().setMag(intersectMag);
          //   if (other.frozen && !other.powerBall) {
          //     this.position.x = this.position.x - scaledDistanceVect.x*2;
          //     this.position.y = this.position.y - scaledDistanceVect.y*2;
          //   } else {
          //     this.position.x = this.position.x - scaledDistanceVect.x/2;
          //     this.position.y = this.position.y - scaledDistanceVect.y/2;
          //   }
          // }

          // float intersectMag = this.radius + other.radius - (distanceVect.mag());
          // PVector scaledDistanceVect = distanceVect.copy().setMag(intersectMag);
          // if (this.frozen && !this.equals(cue_ball) && !other.frozen) {
          //   scaledDistanceVect.mult(1.1);
          //   other.position.x = other.position.x - scaledDistanceVect.x;
          //   other.position.y = other.position.y - scaledDistanceVect.y + 10;
          // } else if (other.frozen && !other.equals(cue_ball) && !this.frozen) {
          //   scaledDistanceVect.mult(1.1);
          //   this.position.x = this.position.x + scaledDistanceVect.x - 10;
          //   this.position.y = this.position.y + scaledDistanceVect.y - 10;
          // }
          // else {
          //   other.position.x = other.position.x + scaledDistanceVect.x/4;
          //   other.position.y = other.position.y + scaledDistanceVect.y/4;
          //   this.position.x = this.position.x - scaledDistanceVect.x/4;
          //   this.position.y = this.position.y - scaledDistanceVect.y/4;
          // }
    
          position.add(bFinal[0]);
    
          // update velocities
          //if (!this.frozen || this.equals(cue_ball)) {
            velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
            velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
          //}
          //if (!other.frozen) {
            other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
            other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
          //}
          velocity.setMag(velocity.mag() * elastic_constant);
          other.velocity.setMag(other.velocity.mag() * elastic_constant);
          
          return true;
        }
      }
      // Neither ball is touching each other in this case.
      // So if either ball is on the others hit list, they can be removed, as they are no longer touching - ONLY if a round has passed
      return false;
    }
    
    // Power up functions here
    
    protected void powerReset() {
      this.thaw();
      shocked = false;
      onFire = false;
    }
    
    // FireBall
    public void alight() {
      if (!onFire) {
        powerReset();
        onFire = true;
        this.effectDuration = fireDuration;
      }
      
    }
    
    // ShockBall
    public void shock() {
      if (!shocked) {
        powerReset();
        shocked = true;
        this.effectDuration = shockDuration;
      } 
    }   
    
    public boolean isShocked() { return shocked; }
    
    // IceBall
    public void freeze() {
      if (!frozen) {
        powerReset();
        frozen = true;
        this.effectDuration = freezeDuration;
        println("freeze duration" + freezeDuration);
        this.mass = 1000000000;
      }
    }    
    
    public void thaw() {
      frozen = false;
      this.mass = this.normalMass;
    }   
    
    // GravityBall
    public void pull(Ball towards) {
      gravity = true;
      // If pocketed, impulse nearby balls towards the hole
      if (pocketed.contains(cue_ball)) {
        PVector direction = towards.position.copy().sub(position);
        velocity = velocity.add(direction.setMag(0.075));
        gravity = false;
      }
      // case of general movement
      else if (!(this.position.dist(cue_ball.position) < this.diameter * 2) && balls.contains(cue_ball)) {
        PVector direction = towards.position.copy().sub(position);
        pullVelocity = direction.setMag(1);
      }
    }
}
