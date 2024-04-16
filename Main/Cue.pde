public class Cue {
    protected PVector originalPosition;
    protected PVector position;
    protected PVector resultant;
    protected float cueLength;
    protected boolean active;
    // angle is locked when user clicks
    protected boolean lockAngle = false;
    protected float angle = 0.0;
    // Cue constructor
    public Cue(PVector _position, float _cueLength) {
        originalPosition = new PVector(_position.copy().x, _position.copy().y)/* _position.copy() */;
        position = new PVector(_position.copy().x, _position.copy().y)/* _position.copy() */;
        resultant = new PVector(0, 0);
        cueLength = _cueLength;
        active = true;
    }
    
    // update the cue position according to player's cursor events
    protected void update(PVector cueBallVector/* , float xStart, float yStart */) {
        // only update if the cue is active
        if (active) {
            if (this.lockAngle == false) {
                resultant = new PVector(0, 0);
                angle = atan2(mouseY - cueBallVector.y, mouseX - cueBallVector.x);
                position.x = cueBallVector.copy().x + base_distance * cos(angle);
                position.y = cueBallVector.copy().y + base_distance * sin(angle);
            } else {
                PVector vectorFromAngle = PVector.fromAngle(this.angle);
                PVector vectorFromMouseToStart = new PVector();
                // if (abs(mouseX - xStart)/* cueBallVector.x */ <= 10 || abs(mouseY - yStart)/* cueBallVector.y */ <= 10) {
                    // vectorFromMouseToStart = new PVector(base_distance * cos(angle)/* 50 * vectorFromAngle.x */, base_distance * sin(angle)/* 50 * vectorFromAngle.y */);
                // } else {
                    vectorFromMouseToStart = new PVector(mouseX - xStart/* cueBallVector.x */, mouseY - yStart/* cueBallVector.y */);
                // }
                float tempDotProduct = vectorFromAngle.copy().dot(vectorFromMouseToStart.copy());
                float dotProduct = 0;
                if (tempDotProduct < max_dot_product / 2) {
                    dotProduct = tempDotProduct;
                } else {
                    // 1. get the dot product of the vector, what distance does vector from Mouse to ball
                    // 2. apply log scale to give it a feeling of more power needed the further the player moves the cue
                    dotProduct = log(1.045 + vectorFromAngle.copy().dot(vectorFromMouseToStart.copy()))/ log(1.045) - log(1.045 + max_dot_product / 2)/log(1.045) + max_dot_product/2;
                }
                
                // debug check
                // println("mouseX - xStart "+ (mouseX - xStart));
                // println("mouseY - yStart "+ (mouseY - yStart));
                // println("vectorFromAngle.copy().dot(vectorFromMouseToStart.copy())"+vectorFromAngle.copy().dot(vectorFromMouseToStart.copy()));
                // println("dotProduct: ", dotProduct);
                // println("xStart: "+ xStart);
                // println("mouseX"+mouseX);
                // println("yStart: "+yStart);
                // println("mouseY: "+mouseY);
                // println("max_dot_product: "+ max_dot_product);

                // set cue position according to the dot product
                if (dotProduct > 0 && dotProduct <= max_dot_product) {
                    position.x = cueBallVector.copy().x + base_distance * cos(angle) + dotProduct * cos(angle);
                    position.y = cueBallVector.copy().y + base_distance* sin(angle) + dotProduct * sin(angle);

                } else if (dotProduct >= max_dot_product) {
                    position.x = cueBallVector.copy().x + base_distance * cos(angle) + max_dot_product * cos(angle);
                    position.y = cueBallVector.copy().y + base_distance * sin(angle) + max_dot_product * sin(angle);
                } else {
                    // reset the position and resultant when the dot product is <= 0
                    // xStart = mouseX;
                    // yStart = mouseY;
                    position.x = originalPosition.copy().x;
                    position.y = originalPosition.copy().y;
                    resultant.x = 0;
                    resultant.y = 0;
                    return;
                }

                // update the resultant vector
                if (dotProduct > 1) {
                    // resultant multiply by the ratio
                    float ratio = max_force * dotProduct/ max_dot_product;
                    resultant.x = originalPosition.copy().x - position.copy().x;
                    resultant.y = originalPosition.copy().y - position.copy().y;
                    // get unit vector 1
                    resultant.normalize();
                    resultant = PVector.mult(resultant, ratio);
                    // check if magnitude is greater than max force
                    resultant.limit(max_force);
                }
                
            }
        }
        
        
    }
    
    // display translate and rotate the cue according to user's cursor
    public void display() {
        pushMatrix();
        translate(position.x, position.y);
        rotate(angle);
        fill(139, 69, 19);
        rectMode(CENTER);
        rect(0, 0, cueLength, 10);
        fill(255);
        square(-cueLength/2, 0, 10);
        popMatrix();
        findAngles();
    }
    
    // lock the angle for user to start adjusting the power
    public void setLockAngle(boolean lock) {
        lockAngle = lock;
    }

    // set starting original position of the cue
    public void setOriginalPosition() {
        originalPosition.x = position.copy().x;
        originalPosition.y = position.copy().y;
    }

    // get the position of the cue
    public PVector getPosition() {
        return this.position;
    }

    // get the resultant when mouse release
    public PVector getResultant() {
        return this.resultant;
    }

    // get the active state of the cue
    public boolean getActive() {
        return this.active;
    }

    // set the active state of the cue (i.e. all balls have stopped)
    public void setActive(boolean _b) {
        print("Set to" + String.valueOf(_b));
        this.active = _b;
    }

    public void findAngles() {
        PVector cueBallVector = cue_ball.position.copy();
        float direction = 0;
        if (lockAngle == false) {
            direction = atan2(mouseY - cueBallVector.y, mouseX - cueBallVector.x);
        } else {
            direction = this.angle;
        }
        
        float lineEndX = cueBallVector.x + cos(direction + PI) * 1000;
        float lineEndY = cueBallVector.y + sin(direction + PI) * 1000;
        // Project a ball forwards every pixel, and find the first ball that hits another
        PVector collidingPosition = null;
        Ball collidingBall = null;
        for (int i = 0; i < 700; i++) {
            PVector coordinates = new PVector(cueBallVector.x + cos(direction + PI) * i, cueBallVector.y + sin(direction + PI) * i);
            for (Ball b : balls) {
                if (b != cue_ball) {
                    if (dist(b.position.x, b.position.y, coordinates.x, coordinates.y) < b.radius+cue_ball.radius) {
                        collidingBall = b;
                        collidingPosition = coordinates;
                    }
                }
            }
            if (collidingBall != null) {
                break;
            }
        }
        // // Check to see if any balls are colliding with the line:
        // Ball collidingBall = null;
        // float collidingDistance = 999999;
        // for (Ball b : balls) {
        //     if (b != cue_ball){
        //         if (lineCircle(cueBallVector.x, cueBallVector.y, lineEndX, lineEndY, b.position.x, b.position.y, b.radius + cue_ball.radius)) {
        //             float distance = dist(cueBallVector.x, cueBallVector.y, b.position.x, b.position.y);
        //             if (distance < collidingDistance) {
        //                 collidingBall = b;
        //                 collidingDistance = distance;
        //             }
        //         }
        //     }
        // }
        // Calculate angles of collision between the two balls - perfect elastic collision
        if (collidingBall != null) {
            line(cue_ball.position.x, cue_ball.position.y, collidingPosition.x, collidingPosition.y);
            circle(collidingPosition.x, collidingPosition.y, cue_ball.diameter);
            // Gets vector between point on line and this ball. When added to the collidingBalls position, gives the position of the cue ball in the future when it hits the ball
            //line(collidingBall.position.x, collidingBall.position.y, collidingBall.position.x + distanceVect.x, collidingBall.position.y + distanceVect.y);
            Ball cueCopy = new Ball(collidingPosition.x, collidingPosition.y, cue_ball.diameter, cue_ball.mass, "red");
            Ball otherCopy = new Ball(collidingBall.position.x, collidingBall.position.y, collidingBall.diameter, collidingBall.mass, "red");
            // Give cue ball a velocity in the direction of its movement.
            cueCopy.velocity = PVector.fromAngle(direction + PI);
            cueCopy.velocity.setMag(100);
            //otherCopy.velocity.setMag(100);
            ballCollisionSimulation(cueCopy, otherCopy);
            cueCopy.velocity.setMag(100);
            otherCopy.velocity.setMag(100);

            //println(cueCopy.position.x + (cueCopy.velocity.x*5000));
            //println(cueCopy.position.y + (cueCopy.velocity.y*5000));
            line(cueCopy.position.x, cueCopy.position.y, cueCopy.position.x + (cueCopy.velocity.x), cueCopy.position.y + (cueCopy.velocity.y));
            line(otherCopy.position.x, otherCopy.position.y, otherCopy.position.x + (otherCopy.velocity.x), otherCopy.position.y + (otherCopy.velocity.y));
            //circle(cueCopy.velocity.x*5000, cueCopy.velocity.y*5000, 5000);
            //circle(cueCopy.position.x, cueCopy.position.y, 5);
        }
        
    }


    // For finding the angles, simulate a collision between the cue ball and the ball it is found to be hitting.
    // This method should taken the velocities and positions of each ball, and return final velocities for each
    // The first ball should be constructed based on the position of the cue, and a large velocity based on the current angle
    // the second ball should be constructed at the position of the other ball, and no velocity
    // The angles can then be extracted from the velocity
    private void ballCollisionSimulation(Ball first, Ball other) {

        // Get distances between the balls components
        PVector distanceVect = PVector.sub(other.position, first.position);

        // Calculate magnitude of the vector separating the balls
        float distanceVectMag = distanceVect.mag();
  
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
  
        vTemp[0].x = cosine * first.velocity.x + sine * first.velocity.y;
        vTemp[0].y = cosine * first.velocity.y - sine * first.velocity.x;
        vTemp[1].x = cosine * other.velocity.x + sine * other.velocity.y;
        vTemp[1].y = cosine * other.velocity.y - sine * other.velocity.x;
  
        /* Now that velocities are rotated, you can use 1D
         conservation of momentum equations to calculate 
         the final velocity along the x-axis. */
        PVector[] vFinal = {  
          new PVector(), new PVector()
        };
  
        // final rotated velocity for b[0]
        vFinal[0].x = ((first.mass - other.mass) * vTemp[0].x + 2 * other.mass * vTemp[1].x) / (first.mass + other.mass);
        vFinal[0].y = vTemp[0].y;
  
        // final rotated velocity for b[0]
        vFinal[1].x = ((other.mass - first.mass) * vTemp[1].x + 2 * first.mass * vTemp[0].x) / (first.mass + other.mass);
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
  
        // update balls to screen position
        //other.position.x = position.x + bFinal[1].x + 1;
        //other.position.y = position.y + bFinal[1].y + 1;
        
        // update velocities
        first.velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
        first.velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
        other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
        other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
    }
}
