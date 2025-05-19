package team17Pkg;

public class Player {
    float x;
    float xMin;
    float xMax;
    float score = 0;
    float theta = 0;

    public Player(float xh, float theta, float xh_min, float xh_max){
        this.update(xh, theta);
        this.xMin = xh_min;
        this.xMax = xh_max;
    }
    public void reset(){
        score = 0;
    }
    public void update(float xh, float theta){
        this.x = xh;
        this.theta = theta;
    }

    private int circleRect(float cx, float cy, float radius, float rx, float ry, float rw, float rh) {
        int out = 0;

        // temporary variables to set edges for testing
        float testX = cx;
        float testY = cy;

        // which edge is closest?
        if (cx < rx)         {testX = rx; out=1;}      // test left edge
        else if (cx > rx+rw) {testX = rx+rw; out=3;}   // right edge
        if (cy < ry)         {testY = ry; out=4;}      // top edge
        else if (cy > ry+rh) {testY = ry+rh; out=2;}   // bottom edge

        // get distance from closest edges
        double distX = cx-testX;
        double distY = cy-testY;
        double distance = Math.sqrt( (distX*distX) + (distY*distY) );

        // if the distance is less than the radius, collision!
        if (distance <= radius) {
            return out;
        }
        return 0;
    }
}
