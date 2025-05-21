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
Encoder myEnc(encoderPinA, encoderPinB);
Encoder myEnc2(encoderPin2A, encoderPin2B);
long prev_Pos = -999;
long prev_Pos2 = -999;
double duty = 0;
unsigned int output = 0;    // output command to the motor
double duty2 = 0;
unsigned int output2 = 0;    // output command to the motor
int counter = 2000;
bool use_M1 = true;

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
}

// --------------------------------------------------------------
// Main Loop
// --------------------------------------------------------------
void loop()
{
  if(Serial.available()){
    String sD = Serial.readString();
    sD.trim();
    int i = sD.indexOf(",");
    duty = sD.substring(0,i).toDouble();
    duty2 = sD.substring(i+1).toDouble();
  }

  long updatedPos = myEnc.read();
  long updatedPos2 = myEnc2.read();
  if (updatedPos != prev_Pos || updatedPos2 != prev_Pos2) {
    Serial.print("Motor 1 = ");
    Serial.print(updatedPos);
    Serial.print(", Motor 2 = ");
    Serial.print(updatedPos2);
    Serial.println();
    prev_Pos = updatedPos;
    prev_Pos2 = updatedPos2;
  }

  counter -= 1;
  if(counter==0) {
    use_M1 = !use_M1;
    counter = 2000;
  }

  if(use_M1){
    duty = 0.2;
    duty2 = 0;
  } else {
    duty = 0;
    duty2 = 0.2;
  }
  
  // Tp = rh*rp/rs*force;
  float force = -0.1;

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
  // duty = sqrt(abs(Tp)/0.0053);
  // duty = sqrt(abs(Tp)/0.03);

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
