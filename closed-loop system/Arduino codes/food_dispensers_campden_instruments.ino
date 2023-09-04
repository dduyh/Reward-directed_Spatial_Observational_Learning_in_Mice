/********************************************************************************************
*        Date:    October 30th, 2022                                                        *
*       Author:  Yihui Du                                                                   *
*  Description:  food_dispensers_campden_instruments                                        *
*                                                                                           *
* Code for the Master board                                                                 *                          
* This script controls two food dispensers seperately,                                      *
* and controls two ustepper doors by another two arduino boards.                            *
*                                                                                           *
********************************************************************************************/

#include<Wire.h>                // This library is used for I2C communication

int left_Address = 2;           // left_Address here is the address of the left slave board 
int right_Address = 3;          // right_Address here is the address of the right slave board 

int x;                          // x value sets the rotation direction of stepper motor

int right_Pin = 12;             // Set the digital pin 12 to control right food dispenser
int left_Pin = 13;              // Set the digital pin 13 to control left food dispenser

int Delay = 1000;               // Set 1000 millisecond delay after each pellet is dispensed
char terminator = '/';          // Set terminator for each input command 
String mode;                    // mode string saves the command mode

// Setup code are put here to run once:
void setup() {
  Serial.begin(9600);           // Begin serial communication (baud rate 9600) with MATLAB 
  Wire.begin();                 // Activate I2C link
  
  pinMode(right_Pin, OUTPUT);   // sets the digital pin 12 as right output
  pinMode(left_Pin, OUTPUT);    // sets the digital pin 13 as left output

  digitalWrite(right_Pin, LOW); // Initiate the right output for the dispense operation
  digitalWrite(left_Pin, LOW);  // Initiate the left output for the dispense operation

  // Print instructions in the serial monitor
  Serial.println("<Arduino is ready>");
  Serial.println("-----------------------------------");
  Serial.println("Command List:");
  Serial.println("-----------------------------------");
  Serial.println("COMMAND: Left/Right food dispenser drop one pellet");
  Serial.println("SYNTAX:  left_food/");
  Serial.println("SYNTAX:  Right_food/");
  Serial.println("-----------------------------------");
  Serial.println("COMMAND: Left/Right door open/close");
  Serial.println("SYNTAX:  left_door_open/");
  Serial.println("SYNTAX:  left_door_close/");
  Serial.println("SYNTAX:  Right_door_open/");
  Serial.println("SYNTAX:  Right_door_close/");
  Serial.println("-----------------------------------");
}

// Main code are put here to run repeatedly:
void loop() {
  while (Serial.available() == 0) {           // Wait for user input
  }
  mode = Serial.readStringUntil(terminator);  // Read the input command from MATLAB to set mode
  
  if (mode == "left_food")                    // The mode is dispensing food into left cage
  {
    digitalWrite(left_Pin, HIGH);             // Set the digital left pin to HIGH
    delay(Delay);                             // Wait for a second
    digitalWrite(left_Pin, LOW);              // Release and wait for the next dispense operation
  }
  if (mode == "Right_food")                   // The mode is dispensing food into right cage
  {
    digitalWrite(right_Pin, HIGH);            // Set the digital right pin to HIGH
    delay(Delay);                             // Wait for a second
    digitalWrite(right_Pin, LOW);             // Release and wait for the next dispense operation
  }
  if (mode == "left_door_open")               // The mode is opening the left cage door
  {
    x = 2;                                    // The value 2 of x means to rotate the stepper motor counterclockwise
    Wire.beginTransmission(left_Address);     // Begin communication with the left slave board 
    Wire.write(x);                            // Transfers the x value to the left slave board            
    Wire.endTransmission();                   // End communication with the left slave board 
  }
  if (mode == "left_door_close")              // The mode is closing the left cage door
  {
    x = 1;                                    // The value 1 of x means to rotate the stepper motor clockwise
    Wire.beginTransmission(left_Address);     // Begin communication with the left slave board 
    Wire.write(x);                            // Transfers the x value to the left slave board          
    Wire.endTransmission();                   // End communication with the left slave board  
  }
  if (mode == "Right_door_open")              // The mode is opening the right cage door
  {
    x = 1;                                    // The value 1 of x means to rotate the stepper motor clockwise
    Wire.beginTransmission(right_Address);    // Begin communication with the right slave board 
    Wire.write(x);                            // Transfers the x value to the right slave board            
    Wire.endTransmission();                   // End communication with the right slave board  
  }
  if (mode == "Right_door_close")             // The mode is closing the right cage door
  {
    x = 2;                                    // The value 2 of x means to rotate the stepper motor counterclockwise
    Wire.beginTransmission(right_Address);    // Begin communication with the right slave board 
    Wire.write(x);                            // Transfers the x value to the right slave board            
    Wire.endTransmission();                   // End communication with the right slave board   
  }
}
