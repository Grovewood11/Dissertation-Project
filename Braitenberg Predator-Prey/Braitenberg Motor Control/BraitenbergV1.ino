String val;// declare global variables
int ledPin = 13;// define led and motor pins
const int LeftMotorDirPin = 7;
const int LeftMotorPwmPin = 9;
const int RightMotorDirPin = 8;
const int RightMotorPwmPin = 10;

int leftSpeed = 0;
int rightSpeed = 0;
int increment = 10;
boolean leftDir = HIGH;
boolean rightDir = HIGH;
boolean ledState = HIGH;
String left;
String right;


void setup(){// begion setup
  pinMode(LeftMotorDirPin, OUTPUT);// set led and motor pins to output
  pinMode(LeftMotorPwmPin, OUTPUT);
  pinMode(RightMotorDirPin, OUTPUT);
  pinMode(RightMotorPwmPin, OUTPUT);
  pinMode(ledPin,OUTPUT);
  Serial.begin(9600);// set correct baud rate
  establishContact();//pauses the code until contact is established
  
  
}

void loop(){// begin loop

  if(Serial.available() > 0){// if serial is available
    
    val = Serial.readStringUntil('Z');// read serial until Z
    
    // isolate left speed string from between A and B
    left = val.substring(val.indexOf('A')+ 1, val.indexOf('B')); 
    
    // isolate right speed string from between B and C
    right = val.substring(val.indexOf('B')+ 1);
    
    // convert the two motor speeds to integers
    leftSpeed = left.toInt(); 
    rightSpeed = right.toInt();
    Serial.println(val);// return the recieved string to confirm receipt
    } 
     
    
     
    // if motor speeds are negative, set directions to backwards
    if (leftSpeed < 0){
      leftDir = LOW;
      ledState = LOW;
    }     
    if (rightSpeed < 0){
      rightDir = LOW;
      ledState = HIGH;
    }
    if (leftSpeed > 0){
      leftDir = HIGH;
      ledState = HIGH;
    }   
    if(rightSpeed > 0){
      rightDir = HIGH;
      ledState = LOW;    
    }
    // ensuring the motor speeds are within the right range
    if(leftSpeed > 255){
      leftSpeed = 255;
    }
    if(rightSpeed > 255){
      rightSpeed = 255;
    }
    if(leftSpeed < -255){
      leftSpeed = -255;
    }
      if(leftSpeed < -255){
      leftSpeed = -255;
    }    
 
    // updat motors
    digitalWrite(-LeftMotorDirPin, leftDir);
    analogWrite(LeftMotorPwmPin, leftSpeed);
    digitalWrite(-RightMotorDirPin, rightDir);
    analogWrite(RightMotorPwmPin, rightSpeed);
    
    delay(100);// paude for 100 ms
}

void establishContact(){
  // print the letter A until anything is recieved
  while(Serial.available() <= 0){
    Serial.println("A");
    ledState = 1;
    delay(300);
  }
  Serial.println("Contact");// serial print contact
}
