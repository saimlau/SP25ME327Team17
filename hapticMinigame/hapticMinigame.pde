// hapticMinigame.pde
/*

 */

import processing.serial.*;
import java.util.Random;
import java.lang.Math;
import java.util.ArrayList;
import team17Pkg.Player;
import team17Pkg.Bricks;

Serial myPort;        // The serial port

//*****************************************************************
//****************** Initialize Variables (START) *****************
//*****************************************************************

// STUDENT CODE HERE
float xh = 0;
float yh;
float pos_x = 0;
float pos_y;
float xh_min = -0.08066;
float xh_max = 0.06323;
float r_b = 0.002;
float r_b_p;
float theta = 0;

float w_brick = 0.006;
float w_brick_p;
float x_brick_max;
float x_brick_min;
float y_brick_max;
float y_brick_min;
float x_brick_max_p;
float x_brick_min_p;
float y_brick_max_p;
float y_brick_min_p;

Bricks brks;
Player usr;
//*****************************************************************
//******************* Initialize Variables (END) ******************
//*****************************************************************


void setup () {
  // set the window size:
  size(1200, 800); 

  // List all the available serial ports
  //println(Serial.list());
  // Check the listed serial ports in your machine
  // and use the correct index number in Serial.list()[].
  //myPort = new Serial(this, Serial.list()[0], 115200);  //make sure baud rate matches Arduino

  // A serialEvent() is generated when a newline character is received :
  //myPort.bufferUntil('\n');
  background(0);      // set inital background:
  r_b_p = map(r_b, 0., xh_max-xh_min, 0., width);
  w_brick_p = map(w_brick, 0., xh_max-xh_min, 0., width);
  //pos_wall = map(x_wall, xh_min, xh_max, 0, width);
  //pos_mass = map(x_mass, xh_min, xh_max, 0, width);
  
  
}
void draw () {
  // everything happens in the serialEvent()
  background(0); //uncomment if you want to control a ball
  stroke(127, 34, 255);     //stroke color
  strokeWeight(4);        //stroke wider
  
  //*****************************************************************
  //***************** Draw Objects in Scene (START) *****************
  //*****************************************************************

  // STUDENT CODE HERE
    
  // (1) draw an ellipse (or other shape) to represent user position
    // HINT: the ellipse (or other shape) should not penetrate the mass object
  //if(pos+r_u<=pos_mass-r_m){
  //  ellipse(pos, height/2, 2*r_u, 2*r_u);
  //} else {
  //  ellipse(pos_mass-r_u-r_m, height/2, 2*r_u, 2*r_u);
  //}
  //// (2) draw an ellipse (or other shape) to represent the mass position
  //ellipse(pos_mass, height/2, 2*r_m, 2*r_m);
  //// (3) draw the wall where the spring & damper are fixed (i.e., at 0.5 cm)
  //line(pos_wall, 0, pos_wall, height);
  //// (4) draw a line between the fixed wall in (3) and the moving mass
  //line(pos_wall, height/2, pos_mass, height/2);

  //*****************************************************************
  //****************** Draw Objects in Scene (END) ******************
  //*****************************************************************
}

void serialEvent (Serial myPort) {
  //*****************************************************************
  //** Read in Handle and Mass Positions from Serial Port (START) ***
  //*****************************************************************
  
  // STUDENT CODE HERE
  
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
    xh = temp1;
    pos_x = map(xh, xh_min, xh_max, 0, width);
  }
  if(temp2 == temp2){
    theta = temp2;
  }
  //*****************************************************************
  //**** Read in Handle and Mass Positions from Serial Port (END) ***
  //*****************************************************************
}
