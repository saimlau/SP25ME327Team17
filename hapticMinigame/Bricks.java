package team17Pkg;

import java.util.Random;
import java.util.ArrayList;
import java.lang.Math;

public class Bricks {
    float xbMin;
    float xbMax;
    float ybMin;
    float ybMax;
    float width;
    int nY;
    int nX;
    float dX;
    float dY;
    boolean[][] brickMat;
    int[][] brickEffects;
    ArrayList<float[]> locations;
    ArrayList<int[]> locID;
    float brickP;
    Random rnd;

    public Bricks(float xbMin, float xbMax, float ybMin, float ybMax, float brickProb, float brickWidth){
        this.xbMin = xbMin;
        this.xbMax = xbMax;
        this.ybMin = ybMin;
        this.ybMax = ybMax;
        this.width = brickWidth;
        this.nX = Math.round((xbMax-xbMin)/width);
        this.nY = Math.round((ybMax-ybMin)/width);
        this.dX = (xbMax-xbMin)/(nX-1);
        this.dY = (ybMax-ybMin)/(nY-1);

        this.rnd = new Random();
        this.brickP = brickProb;
        this.reGenerate();
    }

    public void reGenerate(){
        brickMat = new boolean[nY][nX];
        brickEffects = new int[nY][nX];
        for(int i=0; i<nY; i++){
            for(int j=0; j<nX; j++){
                float temp = rnd.nextFloat();
                if(temp<=this.brickP){
                    brickMat[i][j] = true;
                    brickEffects[i][j] = rnd.nextInt(4);
                }
            }
        }
        this.updateLocations();
    }

    public void updateLocations(){
        locations = new ArrayList<>();
        locID = new ArrayList<>();
        for(int i=0; i<nY; i++){
            for(int j=0; j<nX; j++){
                if(brickMat[i][j]){
                    locations.add(new float[] {xbMin+j*dX, ybMin+i*dY});
                    locID.add(new int[] {i,j});
                }
            }
        }
        if(locations.isEmpty()) reGenerate();
    }
    public ArrayList<float[]> getLocations(){
        return this.locations;
    }

    public int breakBrick(int i, int j){
        brickMat[i][j] = false;
        int temp = brickEffects[i][j];
        brickEffects[i][j] = 0;
        this.updateLocations();
        return temp;
    }
    public int[] checkCollision(float xb, float yb, float rb){
        for(int i = 0; i<locations.size(); i++){
          float[] loc = locations.get(i);
          int temp = circleRect(xb, yb, rb, loc[0]-width/2, loc[1]-width/2, width, width);
          if (temp!=0) {
            int[] ID = locID.get(i);
            return new int[] {temp, ID[0], ID[1]};
          }
        }
        return new int[] {0,0,0};
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
