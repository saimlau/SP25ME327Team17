//--------------------------------------------------------------------------
// Code to test basic Hapkit functionality (sensing and force output)
// Code updated by Cara Nunez 4.17.19
//--------------------------------------------------------------------------
// Parameters that define what environment to render
#define ENABLE_SEND_POS
#define ENABLE_VIRTUAL_WALL
// #define ENABLE_FEEDBACK

// Includes
#include <math.h>
#include <Encoder.h>

// Pin declares
int pwmPin = 5; // PWM output pin for motor 1
int dirPin = 8; // direction output pin for motor 1
int sensorPosPin = A2; // input pin for MR sensor
int fsrPin = A3; // input pin for FSR sensor
int encoderPinA = 2;
int encoderPinB = 3;
Encoder myEnc(encoderPinA, encoderPinB);
long prev_Pos = -999;
// long updatedPos  = -999;

// Position tracking variables
int updatedPos = 0;     // keeps track of the latest updated value of the MR sensor reading
int rawPos = 0;         // current raw reading from MR sensor
int lastRawPos = 0;     // last raw reading from MR sensor
int lastLastRawPos = 0; // last last raw reading from MR sensor
int flipNumber = 0;     // keeps track of the number of flips over the 180deg mark
int tempOffset = 0;
int rawDiff = 0;
int lastRawDiff = 0;
int rawOffset = 0;
int lastRawOffset = 0;
const int flipThresh = 700;  // threshold to determine whether or not a flip over the 180 degree mark occurred
boolean flipped = false;

// Kinematics variables
double xh = 0;           // position of the handle [m]
double theta_s = 0;      // Angle of the sector pulley in deg
double xh_prev;          // Distance of the handle at previous time step
double xh_prev2;
double dxh;              // Velocity of the handle
double dxh_prev;
double dxh_prev2;
double dxh_filt;         // Filtered velocity of the handle
double dxh_filt_prev;
double dxh_filt_prev2;

//*****************************************************************
//****************** Initialize Variables (START) *****************
//*****************************************************************
// Parameters & variables for wall and mass-spring-damper system

// STUDENT CODE HERE
double x_wall = 0.005;
double k_wall = 150;
double rh = 0.089;    //[m]
double rp = 0.005;   //[m]
double rs = 0.074;   //[m] 
double m = 2;
double b = 1;
double k_sp = 300;
double k_user = 1000;
double dt = 0.001;
double r_m = 0.002;
double r_u = 0.002;

int count_down = 0;

//*****************************************************************
//******************* Initialize Variables (END) ******************
//*****************************************************************

// Force output variables
double force = 0;           // force at the handle
double Tp = 0;              // torque of the motor pulley
double duty = 0;            // duty cylce (between 0 and 255)
unsigned int output = 0;    // output command to the motor


// --------------------------------------------------------------
// Setup function -- NO NEED TO EDIT
// --------------------------------------------------------------
void setup() 
{
  // Set up serial communication
  Serial.begin(115200);
  
  // Set PWM frequency 
  setPwmFrequency(pwmPin,1); 
  
  // Input pins
  pinMode(sensorPosPin, INPUT); // set MR sensor pin to be an input
  pinMode(fsrPin, INPUT);       // set FSR sensor pin to be an input

  // Output pins
  pinMode(pwmPin, OUTPUT);  // PWM pin for motor A
  pinMode(dirPin, OUTPUT);  // dir pin for motor A
  
  // Initialize motor 
  analogWrite(pwmPin, 0);     // set to not be spinning (0/255)
  digitalWrite(dirPin, LOW);  // set direction
  
  // Initialize position valiables
  lastLastRawPos = analogRead(sensorPosPin);
  lastRawPos = analogRead(sensorPosPin);
}


// --------------------------------------------------------------
// Main Loop
// --------------------------------------------------------------
void loop()
{
  
  //*************************************************************
  //*** Section 1. Compute position in counts                 ***  
  //*************************************************************

  long updatedPos = myEnc.read();
  // if (updatedPos != prev_Pos) {
  //   prev_Pos = updatedPos;
  //   Serial.println(updatedPos);
  // }
 
  //*****************************************************************
  //************ Compute Position in Meters (START) *****************
  //*****************************************************************
  
  // STUDENT CODE HERE
  double ts = (updatedPos*2*PI/2000)*rp/rs;
  xh = ts*rh;
  
  //*****************************************************************
  //**************** Compute Position in Meters (END) ***************
  //*****************************************************************

  // Calculate velocity with loop time estimation
  dxh = (double)(xh - xh_prev) / 0.001;

  // Calculate the filtered velocity of the handle using an infinite impulse response filter
  dxh_filt = .9*dxh + 0.1*dxh_prev; 
    
  // Record the position and velocity
  xh_prev2 = xh_prev;
  xh_prev = xh;
  
  dxh_prev2 = dxh_prev;
  dxh_prev = dxh;
  
  dxh_filt_prev2 = dxh_filt_prev;
  dxh_filt_prev = dxh_filt;
  
  //*************************************************************
  //****** Assign a Motor Output Force in Newtons (START) *******  
  //*************************************************************
  //*************************************************************
  //******************* Rendering Algorithms ********************
  //*************************************************************
  
  #ifdef ENABLE_SEND_POS
    // STUDENT CODE HERE
    Serial.println(xh, 5);
  #endif

  #ifdef ENABLE_VIRTUAL_WALL
    // STUDENT CODE HERE
    if(xh+r_u>=x_wall){
      force = -k_wall*(xh+r_u-x_wall);
    } else {
      force = 0;
    }
  #endif

  #ifdef ENABLE_FEEDBACK
    // STUDENT CODE HERE
    force = 0;
    if (Serial.available() > 0) {
      String str = Serial.readString();
      str.trim();
      if(str==str){
        count_down = 0; // reset vibration timer
        force = -str.toFloat();
      }
    }
    // if(count_down){
    //   force = -20*dxh_filt;  // vibrate
    //   count_down -= 1;
    // }
  #endif

  // Calculate the motor torque: Tp = ?
  // STUDENT CODE HERE
  Tp = rh*rp/rs*force;

  //*************************************************************
  //******* Assign a Motor Output Force in Newtons (END) ********  
  //*************************************************************
  //*************************************************************


  
  //*************************************************************
  //************ Force output (do not change) *******************
  //*************************************************************

  // Determine correct direction for motor torque
  if(force > 0) { 
    digitalWrite(dirPin, HIGH);
  } else {
    digitalWrite(dirPin, LOW);
  }

  // Compute the duty cycle required to generate Tp (torque at the motor pulley)
  duty = sqrt(abs(Tp)/0.04526300208292487);

  // Make sure the duty cycle is between 0 and 100%
  if (duty > 1) {            
    duty = 1;
  } else if (duty < 0) { 
    duty = 0;
  }  
  output = (int)(duty* 255);   // convert duty cycle to output signal
  analogWrite(pwmPin,output);  // output the signal
}

// --------------------------------------------------------------
// Function to set PWM Freq -- DO NOT EDIT
// --------------------------------------------------------------
void setPwmFrequency(int pin, int divisor) {
  byte mode;
  if(pin == 5 || pin == 6 || pin == 9 || pin == 10) {
    switch(divisor) {
      case 1: mode = 0x01; break;
      case 8: mode = 0x02; break;
      case 64: mode = 0x03; break;
      case 256: mode = 0x04; break;
      case 1024: mode = 0x05; break;
      default: return;
    }
    if(pin == 5 || pin == 6) {
      TCCR0B = TCCR0B & 0b11111000 | mode;
    } else {
      TCCR1B = TCCR1B & 0b11111000 | mode;
    }
  } else if(pin == 3 || pin == 11) {
    switch(divisor) {
      case 1: mode = 0x01; break;
      case 8: mode = 0x02; break;
      case 32: mode = 0x03; break;
      case 64: mode = 0x04; break;
      case 128: mode = 0x05; break;
      case 256: mode = 0x06; break;
      case 1024: mode = 0x7; break;
      default: return;
    }
    TCCR2B = TCCR2B & 0b11111000 | mode;
  }
}
