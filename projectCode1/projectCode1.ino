//--------------------------------------------------------------------------
// Code to test basic Hapkit functionality (sensing and force output)
// Code updated by Cara Nunez 4.17.19
//--------------------------------------------------------------------------
// Parameters that define what environment to render
#define ENABLE_SEND_POS
// #define ENABLE_VIRTUAL_WALL
// #define ENABLE_FEEDBACK

// Includes
#include <math.h>
#include <Encoder.h>

// Pin declares
int pwmPin = 5; // PWM output pin for motor 1
int dirPin = 8; // direction output pin for motor 1
int pwmPin2 = 6; // PWM output pin for motor 1
int dirPin2 = 7; // direction output pin for motor 1
int encoderPinA = 2;
int encoderPinB = 12;
int encoderPin2A = 3;
int encoderPin2B = 13;
Encoder linkEnc(encoderPinA, encoderPinB);
Encoder pullEnc(encoderPin2A, encoderPin2B);
long prev_Pos_link = -999;
long prev_Pos_pull = -999;

// Kinematics variables
double xp = 0;           // position of the paddle [m]
double xp_prev;          // Distance of the paddle at previous time step
double xp_prev2;
double dxp;              // Velocity of the paddle
double dxp_prev;
double dxp_prev2;
double dxp_filt;         // Filtered velocity of the paddle
double dxp_filt_prev;
double dxp_filt_prev2;

double thp = 0;           // angle of paddle [rad]

// Dynamics variables
double Rcap = 0.005;
double Rp = 0.025;
double Rs = 0.048;
double L0 = 0.14;

double Rs = 0.04;
double Lb = 0.04;
double Ls = 0.064;
double Ll = 0.124;



int count_down = 0;

// Force output variables
double force = 0;           // force at the handle
double Tp = 0;              // torque of the motor pulley
double Tp2 = 0;
double duty = 0;            // duty cylce (between 0 and 255)
unsigned int output = 0;    // output command to the motor
double duty2 = 0;           // duty cylce (between 0 and 255)
unsigned int output2 = 0;    // output command to the motor


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
  #ifdef ENABLE_FEEDBACK
    if(Serial.available()){
      String sD = Serial.readString();
      sD.trim();
      int i = sD.indexOf(",");
      force = sD.substring(0,i).toDouble();
      Tp2 = sD.substring(i+1).toDouble();
    }
  #endif
  
  long updatedPos = myEnc.read();
  long updatedPos2 = myEnc2.read();
  
  // Link pos
  double ths = (updatedPos*2*PI/2000);
  xp = L0*sin(ths)/(1+cos(ths));

  // Calculate velocity with loop time estimation
  dxp = (double)(xp - xp_prev) / 0.001;

  // Calculate the filtered velocity of the handle using an infinite impulse response filter
  dxp_filt = .9*dxp + 0.1*dxp_prev; 
    
  // Record the position and velocity
  xp_prev2 = xp_prev;
  xp_prev = xp;
  
  dxp_prev2 = dxp_prev;
  dxp_prev = dxp;
  
  dxp_filt_prev2 = dxp_filt_prev;
  dxp_filt_prev = dxp_filt;

  // Drum pos
  double ths2 = (updatedPos2*2*PI/2000);
  thp = Rcap/Rp*(ths2-xp/Rcap);
  
  #ifdef ENABLE_SEND_POS
    Serial.print(xp, 5);
    Serial.print(",");
    Serial.print(thp,5);
  #endif

  #ifdef ENABLE_VIRTUAL_WALL
    double k_wall = 300;
    double x_wall = 0.05;
    if(xp>=x_wall){
      force = -k_wall*(xp-x_wall);
    } else {
      force = 0;
    }
  #endif

  // Calculate the motor torque: Tp = ?
  Tp = L0/(1+cos(ths))*force;

  
  //*************************************************************
  //************        Force output          *******************
  //*************************************************************

  // Determine correct direction for motor torque
  if(force > 0) { 
    digitalWrite(dirPin, HIGH);
  } else {
    digitalWrite(dirPin, LOW);
  }
  if(Tp2 > 0) { 
    digitalWrite(dirPin2, HIGH);
  } else {
    digitalWrite(dirPin2, LOW);
  }

  // Compute the duty cycle required to generate Tp (torque at the motor pulley)
  duty = sqrt(abs(Tp)/0.04526300208292487);
  duty2 = sqrt(abs(Tp2)/0.04526300208292487);

  // Make sure the duty cycle is between 0 and 100%
  if (duty > 1) {            
    duty = 1;
  } else if (duty < 0) { 
    duty = 0;
  }  
  if (duty2 > 1) {            
    duty2 = 1;
  } else if (duty2 < 0) { 
    duty2 = 0;
  }  
  // Serial.println(duty);
  output = (int)(duty* 255);   // convert duty cycle to output signal
  analogWrite(pwmPin,output);  // output the signal
  output2 = (int)(duty2* 255);   // convert duty cycle to output signal
  analogWrite(pwmPin2,output2);  // output the signal
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
