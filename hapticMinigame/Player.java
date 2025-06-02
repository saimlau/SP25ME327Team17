package team17Pkg;

import processing.serial.*;

public class Player {
    float xp;
    float yp;
    float xMin;
    float xMax;
    int score = 0;
    float thd = 0;
    float wp;
    float hp;
    float relProxyX;
    float relProxyY;
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
        this.relProxyX = this.xp;
        this.relProxyY = this.yp;
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
        float[] relativePos = wframe2bframe(new float[] {xb,yb});
        // System.out.println("("+relativePos[0]+","+relativePos[1]+","+thd+")");
        return circleRect(relativePos[0], relativePos[1], rb, -this.wp/2, -this.hp/2, this.wp, this.hp);
    }
    public void setProxy(float xb, float yb, float rb){
        float[] relativePos = wframe2bframe(new float[] {xb,yb});
        int temp = circleRect(relativePos[0], relativePos[1], rb, -this.wp/2, -this.hp/2, this.wp, this.hp);
        switch (temp) {
            case 1:
                this.relProxyX = -this.wp/2-rb+(float)1e-6;
                this.relProxyY = clip(relativePos[1],this.hp/2);
                break;
            case 2:
                this.relProxyX = clip(relativePos[0],this.wp/2);
                this.relProxyY = this.hp/2+rb-(float)1e-6;
                break;
            case 3:
                this.relProxyX = this.wp/2+rb-(float)1e-6;
                this.relProxyY = clip(relativePos[1],this.hp/2);
                break;
            case 4:
                this.relProxyX = clip(relativePos[0],this.wp/2);
                this.relProxyY = -this.hp/2-rb+(float)1e-6;
                break;
            default:
                break;
        }
    }
    public float[] getBallProxy(){
        return bframe2wframe(new float[] {relProxyX, relProxyY});
    }
    public float[] getForce(float xb, float yb, float rb,float k, Serial thePort){
        float[] relativePos = wframe2bframe(new float[] {xb,yb});
        int dir = circleRect(relProxyX, relProxyY, rb, -this.wp/2, -this.hp/2, this.wp, this.hp);
        float[] relForce = new float[] {0,0};
        float dx = relativePos[0]-relProxyX;
        float dy = relativePos[1]-rb-relProxyY;
        if(dir==1 || dir==3){
            this.relProxyY = clip(relativePos[1],this.hp/2);
            relForce[0] += -k*dx;
        } else if(dir==2 || dir==4){
            this.relProxyX = clip(relativePos[0],this.wp/2);
            relForce[1] += -k*dy;
        }
        float[] temp = bframe2wframe(relForce);
        // thePort.write((-this.xp-temp[0])+","+(relForce[0]*relProxyY+relForce[1]*relProxyX)+"\n");
        // thePort.write((-this.xp-temp[0])+",0.0\n");
        // thePort.write("1\n");
        return new float[] {temp[0]-this.xp, temp[1]-this.yp};
    }
    public float[] reflectFromHit(int hit, int dir, float dxb, float dyb){
        float[] dpb = wframe2bframe(new float[] {dxb+xp, dyb+yp});
        switch(hit) {
            case 1:
                if (dpb[0]*Math.signum(dir)>0){
                    dpb[0] = -dpb[0];
                }
                break;
            case 2:
                if (dpb[1]*Math.signum(dir)<0) {
                    dpb[1] = -dpb[1];
                }
                break;
            case 3:
                if (dpb[0]*Math.signum(dir)<0){
                    dpb[0] = -dpb[0];
                }
                break;
            case 4:
                if (dpb[1]*Math.signum(dir)>0) {
                    dpb[1] = -dpb[1];
                }
                break;
            default:
            break;
        }
        float[] out = bframe2wframe(dpb);
        return new float[] {out[0]-xp, out[1]-yp};
    }

    // Helper functions
    private float[] wframe2bframe(float[] posW){
        float[] relativePos = new float[] {posW[0]-this.xp, posW[1]-this.yp};
        double tempX = Math.cos(this.thd)*relativePos[0] - Math.sin(this.thd)*relativePos[1];
        double tempY = Math.sin(this.thd)*relativePos[0] + Math.cos(this.thd)*relativePos[1];
        relativePos[0] = (float) tempX;
        relativePos[1] = (float) tempY;
        // System.out.println("("+tempX+","+tempY+")");
        return relativePos;
    }
    private float[] bframe2wframe(float[] posB){
        double tempX = Math.cos(this.thd)*posB[0] + Math.sin(this.thd)*posB[1];
        double tempY = -Math.sin(this.thd)*posB[0] + Math.cos(this.thd)*posB[1];
        float x = (float) tempX + this.xp;
        float y = (float) tempY + this.yp;
        return new float[] {x,y};
    }
    private float clip(float value, float max){
        if(value>max) return max;
        if(value<-max) return -max;
        return value;
    }
    private int circleRect(float cx, float cy, float radius, float rx, float ry, float rw, float rh) {
        int out = 4;
        double temp = Math.atan2(cy-(ry+rh/2), cx-(rx+rw/2));
        double angleC = Math.atan2(rh/2,rw/2);
        if((temp>=-Math.PI && temp<-Math.PI+angleC) || (temp>Math.PI-angleC && temp<=Math.PI)){
            out = 1;
        } else if(temp>=-Math.PI+angleC && temp<=-angleC){
            out = 4;
        } else if(temp>-angleC && temp<angleC){
            out = 3;
        } else if(temp>=angleC && temp<=Math.PI-angleC){
            out = 2;
        }

        // temporary variables to set edges for testing
        float testX = cx;
        float testY = cy;

        // which edge is closest?
        if (cx < rx)         {testX = rx;}      // test left edge
        else if (cx > rx+rw) {testX = rx+rw;}   // right edge
        if (cy < ry)         {testY = ry;}      // top edge
        else if (cy > ry+rh) {testY = ry+rh;}   // bottom edge

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
