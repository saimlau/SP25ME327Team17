package team17Pkg;

public class Player {
    float xp;
    float yp;
    float xMin;
    float xMax;
    int score = 0;
    float thd = 0;
    float wp;
    float hp;
    String name;

    public Player(String name, float xp, float yp, float thd, float wp, float hp, float xMin, float xMax){
        this.updateX(xp);
        this.updateTh(thd);
        this.yp = yp;
        this.wp = wp;
        this.hp = hp;
        this.xMin = xMin;
        this.xMax = xMax;
        this.name = name;
    }
    public void reset(){
        score = 0;
    }
    public void scored(){
        score ++;
    }
    public String getName(){
        return this.name;
    }
    public int getScore(){
        return this.score;
    }
    public void updateX(float xp){
        this.xp = xp;
    }
    public void updateTh(float thd){
        this.thd = thd;
    }
    public float getX(){
        return xp;
    }
    public float getTh(){
        return thd;
    }
    public int checkCollision(float xb, float yb, float rb){
        return circleRect(xb, yb, rb, this.xp-this.wp/2, this.yp-this.hp/2, this.wp, this.hp);
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
