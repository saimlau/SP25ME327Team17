// hapticMinigame.pde
/*

 */

import processing.serial.*;
import java.util.Random;
import java.lang.Math;
import java.util.ArrayList;
import java.util.Iterator;
import team17Pkg.Player;
import team17Pkg.Bricks;

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
float xMin = -0.1-wp/2;
float xMax = 0.1+wp/2;
float yMin = 0;
float yMax = xMax-xMin;

float xp_p;
float yp_p;
float xb_p;
float yb_p;
float rb_p;
float wp_p;
float hp_p;

float brickWidth = 0.01;
float brickWidth_p;

ArrayList<float[]> brickLocations;

Bricks brks;
Player usr;

boolean started = true;
//*****************************************************************
//******************* Initialize Variables (END) ******************
//*****************************************************************




void setup () {
  // set the window size:
  size(1200, 1200); 

  // List all the available serial ports
  //println(Serial.list());
  // Check the listed serial ports in your machine and use the correct index number in Serial.list()[].
  myPort = new Serial(this, Serial.list()[0], 115200);  //make sure baud rate matches Arduino

  // A serialEvent() is generated when a newline character is received :
  myPort.bufferUntil('\n');
  background(0);      // set inital background:
  yp_p = height*9/10;
  yp_init = p2r(yp_p,"y");
  usr = new Player(xp_init, yp_init, thd_init, wp, hp, xMin, xMax);
  brks = new Bricks(xMin+brickWidth, xMax-brickWidth, yMax/8+brickWidth/2, yMax*7/10-brickWidth/2, 0.3, brickWidth);
  
  yb = yp_init-0.03;
  rb_p = r2p(rb, "y");
  
  wp_p = r2p(wp,"y");
  hp_p = r2p(hp,"y");
  
  brickWidth_p = r2p(brickWidth,"y");
}
void draw () {
  if(started){
    updateDynamics();
  }
  xp_p = r2p(usr.getX(),"x");
  brickLocations = brks.getLocations();
  xb_p = r2p(xb,"x");
  yb_p = r2p(yb,"y");
  
  background(0);
  stroke(127, 34, 255);     //stroke color
  strokeWeight(4);        //stroke wider
  fill(255);
  
  pushMatrix(); // Save the current state
  translate(xp_p, yp_p); // Translate to the center
  rotate(-usr.getTh()); // Rotate around the center
  rect(-wp_p/2, -hp_p/2, wp_p, hp_p); // Draw paddle
  popMatrix(); // Restore the previous state
  
  ellipse(xb_p, yb_p, 2*rb_p, 2*rb_p);
  
  for(int i = 0; i<brickLocations.size(); i++){
    float[] loc = brickLocations.get(i);
    float[] loc_p = new float[] {r2p(loc[0],"x"), r2p(loc[1],"y")};
    rect(loc_p[0]-brickWidth_p/2, loc_p[1]-brickWidth_p/2, brickWidth_p, brickWidth_p);
  }
  
  if(!started){
    noStroke();
    fill(150, 120);
    rect(0,0,width,height);
  }
  textSize(30);
  fill(255);
  text("Score: "+usr.getScore(), 21, 40, 300, 60);  // Text wraps within text box
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

void updateDynamics(){
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
