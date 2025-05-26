// hapticMinigame.pde
/*

 */

import processing.serial.*;
import java.util.Random;
import java.lang.Math;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Map.Entry;
import team17Pkg.*;

Serial myPort;        // The serial port

//*****************************************************************
//****************** Initialize Variables (START) *****************
//*****************************************************************

float xp_init = 0;
float yp_init;
float thd_init = 0;
float xb = 0;
float yb;
float rb = 0.005;
float wp = 0.05;
float hp = 0.016;
float xMin = -0.1;
float xMax = 0.1;
float yMin = 0;
float yMax = xMax-xMin;

float xp_p;
float yp_p;
float xb_p;
float yb_p;
float rb_p;
float wp_p;
float hp_p;

boolean collidedWithUser = false;
float k = 300;

float brickWidth = 0.01;
float brickWidth_p;

ArrayList<float[]> brickLocations;

Bricks brks;
Player usr;
LeaderBoard ledBrd;

boolean started = false;
float mb = 2;
float dxb = 0.0;
float dyb = 0.05;
float dxb_prev = 0;
float dyb_prev = 0;
float ddxb_prev = 0;
float ddyb_prev = 0;
int eff = 0;
long time_prev;
String ledBrdFilename = "ledbrd.txt";

int buttonX_p;
int buttonY_p;
int buttonW_p;
int buttonH_p;

TEXTBOX nameInput;
//*****************************************************************
//******************* Initialize Variables (END) ******************
//*****************************************************************




void setup () {
  // set the window size:
  size(1200, 1200); 

  // List all the available serial ports
  //println(Serial.list());
  // Check the listed serial ports in your machine and use the correct index number in Serial.list()[].
  //myPort = new Serial(this, Serial.list()[0], 115200);  //make sure baud rate matches Arduino

  // A serialEvent() is generated when a newline character is received :
  //myPort.bufferUntil('\n');
  background(0);      // set inital background:
  yp_p = height*9/10;
  yp_init = p2r(yp_p,"y");
  
  yb = yp_init-0.03;
  rb_p = r2p(rb, "y");
  
  wp_p = r2p(wp,"y");
  hp_p = r2p(hp,"y");
  
  brickWidth_p = r2p(brickWidth,"y");
  
  buttonW_p = width/5;
  buttonH_p = height/12;
  buttonX_p = (width-buttonW_p)/2;
  buttonY_p = (width-buttonH_p)/2;
  
  nameInput = new TEXTBOX();
  nameInput.W = buttonW_p*7/6;
  nameInput.H = 35;
  nameInput.X = (width-nameInput.W)/2;
  nameInput.Y = buttonY_p-nameInput.H-30;
  nameInput.Text = "Unknown Player";
  nameInput.TextLength = 14;
  
  usr = new Player("Testing123", xp_init, yp_init, thd_init, wp, hp, xMin, xMax);
  brks = new Bricks(xMin+brickWidth, xMax-brickWidth, yMax/8+brickWidth/2, yMax*7/10-brickWidth/2, 0.2, brickWidth);
  
  String[] lines = loadStrings(ledBrdFilename);
  ledBrd = new LeaderBoard(lines);  // initiate leader board, reads file if previous save exists
  
  time_prev = System.nanoTime();
}

void startGame(){
  String name = nameInput.Text;
  if(name.equals("")){
    name = "Unknown";
  }
  usr = new Player(name, xp_init, yp_init, thd_init, wp, hp, xMin, xMax);
  time_prev = System.nanoTime();
  started = true;
}

void mousePressed() {
  if(!started){
    if (overButton()) {
      startGame();
    }
  }
  nameInput.PRESSED(mouseX, mouseY);
}
void keyPressed(){
  if(nameInput.KEYPRESSED(key, keyCode)){
    startGame();
  }
}

boolean overButton(){
  if (mouseX >= buttonX_p && mouseX <= buttonX_p+buttonW_p && 
      mouseY >= buttonY_p && mouseY <= buttonY_p+buttonH_p) {
    return true;
  } else {
    return false;
  }
}

void draw () {
  if(started){
    updateDynamics();
  }
  xp_p = r2p(usr.getX(),"x");
  brickLocations = brks.getLocations();
  if(!collidedWithUser){
    xb_p = r2p(xb,"x");
    yb_p = r2p(yb,"y");
  } else {
    float[] proxyPos = usr.getBallProxy();
    xb_p = r2p(proxyPos[0],"x");
    yb_p = r2p(proxyPos[1],"y");
  }
  
  background(0);
  stroke(127, 34, 255);     //stroke color
  strokeWeight(4);        //stroke wider
  fill(255);
  
  pushMatrix(); // Save the current state
  translate(xp_p, yp_p); // Translate to the center
  rotate(-usr.getTh()); // Rotate around the center
  rect(-wp_p/2, -hp_p/2, wp_p, hp_p); // Draw paddle
  popMatrix(); // Restore the previous state
  
  fill(144, 238, 144);
  stroke(27, 252, 6);
  ellipse(xb_p, yb_p, 2*rb_p, 2*rb_p);
  
  fill(255);
  stroke(255,92,0);
  for(int i = 0; i<brickLocations.size(); i++){
    float[] loc = brickLocations.get(i);
    float[] loc_p = new float[] {r2p(loc[0],"x"), r2p(loc[1],"y")};
    rect(loc_p[0]-brickWidth_p/2, loc_p[1]-brickWidth_p/2, brickWidth_p, brickWidth_p);
  }
  
  if(!started){
    noStroke();
    fill(150, 120);
    rect(0,0,width,height);
    
    fill(83, 86, 90, 150);
    stroke(140, 21, 21);  // Cardinal red
    int h_temp = ledBrd.getNum()*24 + 60;
    rect(870,40,300,h_temp,30,30,30,30);
    fill(255);
    textSize(30);
    textAlign(CENTER, CENTER);
    text("Leaderboard", 870, 40, 300, 45);
    textSize(21);
    textAlign(LEFT, TOP);
    text(ledBrd.getStr(true), 900, 93, 270, h_temp);
    
    stroke(0);
    if (overButton()) {
      fill(144, 238, 144);
    } else {
      fill(0, 100, 0);
    }
    rect(buttonX_p,buttonY_p,buttonW_p,buttonH_p,10,10,10,10);
    fill(255);
    textSize(30);
    textAlign(CENTER, CENTER);
    text("PLAY",buttonX_p,buttonY_p,buttonW_p,buttonH_p);
    
    textAlign(CENTER, CENTER);
    nameInput.DRAW();
  }
  textSize(30);
  fill(255);
  textAlign(LEFT,CENTER);
  text("Score: "+usr.getScore(), 21, 40, 300, 30);  // Text wraps within text box
}

void serialEvent (Serial myPort) {  
  // (1) read the input string
    // HINT: use myPort.readStringUntil() with the appropriate argument
  String msg = myPort.readStringUntil('\n');
  float temp1 = 0;
  float temp2 = 0;
    
  // (2) if the input is null, don't do anything else
  if(msg==null){
    return;
  }
  // (3) else, trim and convert string to a number
  else {
    msg = trim(msg);
    String[] temp3 = msg.split(",");
    temp1 = float(temp3[0]);
    temp2 = float(temp3[1]);
  }
  // (4) if the number is NaN, set current value to previous value
  //     otherwise: map the new value to the screen width
  //     & update previous value variable
  if(temp1 == temp1){
    usr.updateX(temp1);
  }
  if(temp2 == temp2){
    usr.updateTh(temp2);
  }
}

void stop() {
  return;
} 

void updateDynamics(){
  double dt = (System.nanoTime()-time_prev)/1000000000.0;
  time_prev = System.nanoTime();
  float[] force = new float[] {0,0};
  
  if(!collidedWithUser){
    int hitU = usr.checkCollision(xb,yb,rb);
    if(hitU!=0){
      collidedWithUser = true;
      usr.setProxy(xb,yb);
    }
  }
  if(collidedWithUser){
    float[] proxyPos = usr.getBallProxy();
    float[] usrForce = usr.getForce(xb,yb,rb,k);
    force[0] += usrForce[0];
    force[1] += usrForce[1];
    if(usr.checkCollision(xb,yb,rb)==0 && usr.checkCollision(xb,yb,rb*1.2)==usr.checkCollision(proxyPos[0],proxyPos[1],rb)){
      collidedWithUser = false;
    }
  }
  //reflectFromHit(hitU, 1);
  
  dxb += (force[0]/mb + ddxb_prev)/2*dt;
  dyb += (force[1]/mb + ddyb_prev)/2*dt;
  dxb = clip(dxb,0.1);
  dyb = clip(dyb,0.1);
  
  int[] hitB = brks.checkCollision(xb,yb,rb);
  if(reflectFromHit(hitB[0], 1)){
    usr.scored();
    eff = brks.breakBrick(hitB[1],hitB[2]);
  }
  
  int hitW = checkWallColllision();
  if(hitW==2){
    if(!collidedWithUser){
      gameOver();
    }
  }else{
    reflectFromHit(hitW, -1);
  }
  
  xb += (dxb + dxb_prev)/2*dt;
  yb += (dyb + dyb_prev)/2*dt;
  
  dxb_prev = dxb;
  dyb_prev = dyb;
  ddxb_prev = force[0]/mb;
  ddyb_prev = force[1]/mb;
}

float r2p(float value, String dir){
  if(dir=="x") {
    return map(value, xMin, xMax, 0, width);
  } else {
    return map(value, yMin, yMax, 0, height);
  }
}

float p2r(float value, String dir){
  if(dir=="x") {
    return map(value, 0, width, xMin, xMax);
  } else {
    return map(value, 0, height, yMin, yMax);
  }
}

void giveFeedback(float force, float Tp2){
  myPort.write(Float.toString(force));
  myPort.write(",");
  myPort.write(Tp2+"\n");
}

int checkWallColllision(){
  if(xb+rb>=xMax) {return (int) 3;}
  if(xb-rb<=xMin) {return (int) 1;}
  if(yb+rb>=yMax) {return (int) 2;}
  if(yb-rb<=yMin) {return (int) 4;}
  return 0;
}

void gameOver(){
  started = false;
  brks.reGenerate();
  ledBrd.recordScore(usr.getName(), usr.getScore());
  String[] list = split(ledBrd.getStr(false), '\n');
  saveStrings(ledBrdFilename, list);
  xb = 0;
  yb = yp_init-0.03;
  dxb = 0.0;
  dyb = 0.05;
  dxb_prev = 0;
  dyb_prev = 0;
  ddxb_prev = 0;
  ddyb_prev = 0;
  eff = 0;
}

float clip(float value, float max){
  if(value>max) return max;
  if(value<-max) return -max;
  return value;
}

boolean reflectFromHit(int hit, int dir){
  switch(hit) {
    case 1:
      if (dxb*Math.signum(dir)>0){
        dxb = -dxb;
        dxb_prev = -dxb_prev;
        return true;
      }
      break;
    case 2:
      if (dyb*Math.signum(dir)<0) {
        dyb = -dyb;
        dyb_prev = -dyb_prev;
        return true;
      }
      break;
    case 3:
      if (dxb*Math.signum(dir)<0){
        dxb = -dxb;
        dxb_prev = -dxb_prev;
        return true;
      }
      break;
    case 4:
      if (dyb*Math.signum(dir)>0) {
        dyb = -dyb;
        dyb_prev = -dyb_prev;
        return true;
      }
      break;
    default:
      break;
  }
  return false;
}
