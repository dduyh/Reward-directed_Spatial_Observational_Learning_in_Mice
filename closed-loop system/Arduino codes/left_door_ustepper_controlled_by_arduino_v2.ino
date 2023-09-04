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

#include <uStepperS.h>                   // This library is used for controlling stepper motor
#include<Wire.h>                         // This library is used for I2C communication

#define NODE_ADDRESS 2                   // The unique address for each I2C slave board

uStepperS stepper;                       // Create an object of the uStepper S
float up_angle = 1040.0;                 // Amount of degrees to move up
float down_angle = -1040.0;              // Amount of degrees to move down

int x;                                   // x value sets the rotation direction of stepper motor

boolean down_flag = true;                // Boolean value record the down status of cage door
boolean up_flag = true;                  // Boolean value record the up status of cage door

// Setup code are put here to run once:
void setup() {
  stepper.setup();                       // Initialisation of the uStepper S
  stepper.setMaxAcceleration(8000);      // Set an acceleration of 2000 fullsteps/s^2
  stepper.setMaxVelocity(2000);          // Set max velocity of 500 fullsteps/s

  Serial.begin(9600);                    // Begin serial communication (baud rate 9600) with MATLAB 
  Wire.begin(NODE_ADDRESS);              // Activate I2C network
  Wire.onReceive(receiveEvent);          // Set the slave node to receive value from master board
}

void receiveEvent(int bytes) {           // Define a founction to receive value from master board
  while (Wire.available()) {
    x = Wire.read();                     // Receive value from master board
  }
}

// Main code are put here to run repeatedly:
void loop() {
  if (x == 1) {                          // The value 1 of x means to move down the left cage door
    if (down_flag) {                     // If the cage door is still closed
      if (!stepper.getMotorState())      // If motor is at standstill
      {
        stepper.moveAngle(down_angle);   // Start to move down
        down_flag = false;               // Set the down status of cage door to false
        up_flag = true;                  // Set the up status of cage door to true
        delay(1000);                     // Wait for a second
      }
    }
  }
  if (x == 2) {                          // The value 2 of x means to move up the left cage door
    if (up_flag) {                       // If the cage door is still open
      if (!stepper.getMotorState())      // If motor is at standstill
      {
        stepper.moveAngle(up_angle);     // Start to move up
        up_flag = false;                 // Set the up status of cage door to false
        down_flag = true;                // Set the down status of cage door to true
        delay(1000);                     // Wait for a second
      }
    }
  }
}
