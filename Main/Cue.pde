public class Cue {
    protected PVector originalPosition;
    protected PVector position;
    protected PVector resultant;
    protected float cueLength;
    // angle is locked when user clicks
    protected boolean lockAngle = false;
    protected float angle = 0.0;
    // Cue constructor
    public Cue(PVector _position, float _cueLength) {
        originalPosition = new PVector(_position.copy().x, _position.copy().y)/* _position.copy() */;
        position = new PVector(_position.copy().x, _position.copy().y)/* _position.copy() */;
        resultant = new PVector(0, 0);
        cueLength = _cueLength;
    }
    
    // update the cue position according to player's cursor events
    protected void update(PVector cueBallVector/* , float xStart, float yStart */) {
        if (this.lockAngle == false) {
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
            println("mouseX - xStart "+ (mouseX - xStart));
            println("mouseY - yStart "+ (mouseY - yStart));
            println("vectorFromAngle.copy().dot(vectorFromMouseToStart.copy())"+vectorFromAngle.copy().dot(vectorFromMouseToStart.copy()));
            println("dotProduct: ", dotProduct);
            println("xStart: "+ xStart);
            println("mouseX"+mouseX);
            println("yStart: "+yStart);
            println("mouseY: "+mouseY);
            println("max_dot_product: "+ max_dot_product);

            // set cue position according to the dot product
            if (dotProduct > 0 && dotProduct <= max_dot_product) {
                println("1");
                position.x = cueBallVector.copy().x + base_distance * cos(angle) + dotProduct * cos(angle);
                position.y = cueBallVector.copy().y + base_distance* sin(angle) + dotProduct * sin(angle);

            } else if (dotProduct >= max_dot_product) {
                println("2");
                position.x = cueBallVector.copy().x + base_distance * cos(angle) + max_dot_product * cos(angle);
                position.y = cueBallVector.copy().y + base_distance * sin(angle) + max_dot_product * sin(angle);
            } else {
                println("3");
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
                resultant.x = originalPosition.copy().x - position.copy().x;
                resultant.y = originalPosition.copy().y - position.copy().y;
                resultant.limit(max_force);
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
        rect(0, 0, cueLength, 20);
        fill(255);
        square(-cueLength/2, 0, 20);
        popMatrix();
    }
    
    // lock the angle for user to start adjusting the power
    public void setLockAngle(boolean lock) {
        lockAngle = lock;
        println("setLockAngle");
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
}
