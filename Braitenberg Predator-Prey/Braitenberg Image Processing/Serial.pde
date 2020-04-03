Serial myPort;
String valcontact;
String serialIn;
boolean firstContact = false;
String serialOut;

void initialiseSerial(){
  // selects correct port  
  String portName = Serial.list()[2];
  
  myPort = new Serial(this, portName, 9600);// creates serial port with the chosen port and correct baud rate
  myPort.bufferUntil('\n');// dont read port until end of line
  establishContact();// pauses code until contact is established
}

void establishContact(){// pauses code until contact is found
  while(firstContact == false){// holds code until true
    valcontact = myPort.readStringUntil('\n');// read string until end of line
    
    if(valcontact != null){// if string is available
      valcontact = trim(valcontact);// trim input to prevent noise
      println(valcontact);// print value for user
      if(valcontact.equals("A")){// if input is A
        myPort.clear();// clear any values from  port
        firstContact = true;// register first contact
        myPort.write("A");// send A back over port
        println("Contact");// output contact for user
      }
    }  
  }
}


void serialRead(){// read values passed from the minidriver
  serialIn = myPort.readStringUntil('\n');// read until the end of the line
  if(serialIn != null){// if value available...
    serialIn = trim(serialIn);// trim value to prevent noise
    
  }
  
}

void serialWrite(int motors[]){// writing values to the minidriver
  String outArray[] = {"A", "0", "B", "0", "Z"};
  // string structured so the variables can be read between the letters
  
  // translate the values to analogue integers the motors can use

  
  // add integers to the string
   if(stop == false){
     outArray[1] = str(motors[0]);
     outArray[3] = str(motors[1]);
   }
   else{
     outArray[1] = str(0);
     outArray[3] = str(0);
   }  
  // detect and add the third value (dependant on mouse)
 
  // convert array into a string
  serialOut = join(outArray,"");
  myPort.write(serialOut);// pass the string to the minidriver
  delay(100);// pause for 100 ms
}
