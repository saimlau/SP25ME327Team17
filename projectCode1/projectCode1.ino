//--------------------------------------------------------------------------
// Code for SP25 ME 327 Team 17 Final Project Hapkit boards
// Code updated by Saimai Lau 6.2.25
//--------------------------------------------------------------------------
// Parameters that define what environment to render
// #define ENABLE_SEND_POS     // For the board reading the encoders
#define ENABLE_FEEDBACK     // For the board controlling the motors
#define ENABLE_VIBRATION    // For the board controlling the motors

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

int vibroMPin = 9;

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
double Rcap = 0.0045;
double Rp = 0.025;
double Rs = 0.04;
double L0 = 0.14;

double Lb = 0.04;
double Ls = 0.064;
double Ll = 0.124;

int count_down = 0;

// Force output variables
double force = 0;           // force at the handle
double Tp = 0;              // torque of the motor pulley
double Tp_inter = 0;
double Tp2 = 0;
double duty = 0;            // duty cylce (between 0 and 255)
unsigned int output = 0;    // output command to the motor
double duty2 = 0;           // duty cylce (between 0 and 255)
unsigned int output2 = 0;    // output command to the motor

int vibrate = 0;
int vibSign = 1;

// --------------------------------------------------------------
// Setup function -- NO NEED TO EDIT
// --------------------------------------------------------------
void setup() 
{
  // Set up serial communication
  Serial.begin(115200);
  
  // Set PWM frequency 
  setPwmFrequency(pwmPin,1); 
  setPwmFrequency(pwmPin2,8); 

  // Output pins
  pinMode(pwmPin, OUTPUT);  // PWM pin for motor A
  pinMode(dirPin, OUTPUT);  // dir pin for motor A
  pinMode(pwmPin2, OUTPUT);  // PWM pin for motor B
  pinMode(dirPin2, OUTPUT);  // dir pin for motor B
  
  // Initialize motor 
  analogWrite(pwmPin, 0);     // set to not be spinning (0/255)
  digitalWrite(dirPin, LOW);  // set direction
  analogWrite(pwmPin2, 0);     // set to not be spinning (0/255)
  digitalWrite(dirPin2, LOW);  // set direction

  pinMode(vibroMPin, OUTPUT);
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
      if(sD.substring(0,1)!="V"){
        int i = sD.indexOf(",");
        force = -sD.substring(0,i).toDouble();
        Tp_inter = sD.substring(i+1).toDouble();
      } else if(sD.substring(0,1)=="V"){
        vibrate = sD.substring(1).toFloat();
      }
    }
  #endif
  
  long updatedPos = -linkEnc.read();
  long updatedPos2 = pullEnc.read();
  
  // // Link pos
  // double ths = (updatedPos*2*PI/2000)*Rcap/Rs;
  double ths = asin(xp/sqrt(pow(L0,2)+pow(xp,2)))+atan(xp/L0);
  // xp = L0*sin(ths)/(1+cos(ths));

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
  thp = Rcap/Rp*(ths2-xp*184.9796);
  // thp = ths2;
  
  #ifdef ENABLE_SEND_POS
    Serial.print(xp, 5);
    Serial.print(",");
    Serial.println(thp,5);
  #endif

  #ifdef ENABLE_VIBRATION
    // if(Serial.available()){
    //   String sD = Serial.readString();
    //   sD.trim();
    //   vibrate = sD.toFloat();
    // }
    double b = 3;
    double x_wall = 0.02;
    if(vibrate==1){
      // if (dxp_filt>=0) Tp_inter = b*0.1;
      // else Tp_inter = -b*0.02;
      if (!count_down){
        count_down = 100;
      }
      if(count_down%25==0){
        vibSign = -vibSign;
      }
      Tp_inter = b*0.006*vibSign;
      analogWrite(vibroMPin, 150);
      // delay(1000);
      count_down -= 1;
    } else {
      Tp_inter = 0;
      analogWrite(vibroMPin, 0);
      count_down = 0;
    }
  #endif

  // Calculate the motor torque: Tp = ?
  Tp = L0/(1+cos(ths))*force/Rs*Rcap;
  Tp2 = Tp_inter/Rp*Rcap;

  
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
  // Serial.println(force);
  // Serial.println(Tp2);

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
