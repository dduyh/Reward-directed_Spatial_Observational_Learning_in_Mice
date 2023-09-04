/********************************************************************************************
      	Date: 	 October 30th, 2022
        Author:  Yihui Du
   Description:  right_door_ustepper_controlled_by_arduino
*                                                                                           *
  Code for the slave board
  This script demonstrates how the library can be used to move the motor a specific angle,
  Set the acceleration/velocity and read out the angle moved !
*                                                                                           *
  For more information, check out the documentation:
                 http://ustepper.com/docs/usteppers/html/index.html
*                                                                                           *
********************************************************************************************/

#include <uStepperS.h>
#include<Wire.h>          //This library is used for I2C communication

#define NODE_ADDRESS 3  // Change this unique address for each I2C slave node

uStepperS stepper;
float up_angle = 1040.0;      //amount of degrees to move up
float down_angle = -1040.0;      //amount of degrees to move down

int x;

boolean down_flag = true;
boolean up_flag = true;

void setup() {
  // put your setup code here, to run once:
  stepper.setup();        //Initialisation of the uStepper S
  stepper.setMaxAcceleration(8000);     //use an acceleration of 2000 fullsteps/s^2
  stepper.setMaxVelocity(2000);          //Max velocity of 500 fullsteps/s
  // stepper.checkOrientation(30.0);       //Check orientation of motor connector with +/- 30 microsteps movement
  Serial.begin(9600);
  Wire.begin(NODE_ADDRESS);  // Activate I2C network
  Wire.onReceive(receiveEvent);
}

void receiveEvent(int bytes) {
  while (Wire.available()) {
    x = Wire.read();//Receive value from master board
    //Serial.print(x);
  }
}

void loop() {
  // put your main code here, to run repeatedly:

  if (x == 1) {
    if (down_flag) {
      if (!stepper.getMotorState())         //If motor is at standstill
      {
        stepper.moveAngle(down_angle);           //start new movement
        down_flag = false;
        up_flag = true;
        delay(1000);
      }
    }
  }
  if (x == 2) {
    if (up_flag) {
      if (!stepper.getMotorState())         //If motor is at standstill
      {
        stepper.moveAngle(up_angle);           //start new movement
        up_flag = false;
        down_flag = true;
        delay(1000);
      }
    }
  }
}
