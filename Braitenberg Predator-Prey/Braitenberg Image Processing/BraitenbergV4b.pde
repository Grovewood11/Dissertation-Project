import processing.serial.*;// import processing and serial libraries
import gohai.glvideo.*;// import video libraries
GLCapture video;


// initialise global variables
PFont text;// initialse text
ArrayList<blob> blobx = new ArrayList<blob>();//create an array of blobs
ArrayList<colour> colourx = new ArrayList<colour>();//create an array of blobs

int imgWidth = 640;
int imgHeight = 480;
int scale = 4;// easily adjust the resolution of the video
int vidWidth = imgWidth/scale;
int vidHeight = imgHeight/scale;
int maxTarget = 2;
int viewTarget = 0;
int callibration = 0;
int range = 100;
int baseSpeed = 50;
boolean stop = true;

String menuIndent[] = {""," -- ","","","","","","","","",""};

float speedScale = 1;

boolean menu = true;
int mainSelect = 1;
int sumPriority = 100;

void setup() {// begin setup
  size(1000, 480, P2D);// create window 640x480 pixels 
  
  initialiseCamera();
  initialiseSerial();
  initialiseColour();
}

void initialiseCamera(){
  // print all found camera devices
  String[] devices = GLCapture.list();
  println("Devices:");
  printArray(devices);
 
  // if any camera device found, print configs
  if (0 < devices.length) {
    String[] configs = GLCapture.configs(devices[0]);
    println("Configs:");
    printArray(configs);
  }
  
  // begin video with first camera found
  video = new GLCapture(this, devices[0], vidWidth, vidHeight, 30);
  video.start();
  
}
void initialiseColour(){
  colourx.clear();
  for(int i = 0; i < maxTarget; i++){
     colourx.add(new colour(i));
  }
}


void draw() {// begin loop
  background(0);// set background to black
  blobx.clear();// clear any blobs from the previous frame
   
  if (video.available()) {// if information available read video
    video.read();
  }
  
  blobRecog();
  
  image(video, 0, 0, 640, 480);// draw current frame
  for(blob b : blobx){// draw every blob
    b.printblob();
    
  }
  
  int motors[] = new int[2];
  if(sumPriority == 100){
    motors = areaToSpeed(motors);
  }
  else{
    motors[0] = 0;
    motors[1]= 0;
  }
  
  drawGui(motors);// shows information about target colours
  serialRead();
  serialWrite(motors);
}


void blobRecog(){
for(int x = 0; x < imgHeight; x++ ){// for each pixel...
  for (int y = 0; y < imgHeight; y++){ 
  
    float frameRGB[] = {red(video.get(x,y)),green(video.get(x,y)),blue(video.get(x,y))};// find rgb values for each pixel
    for(colour c: colourx){ 
      c.colourRGB(frameRGB, x, y);     
    }
  }
  }
}

int[] areaToSpeed(int motors[]){
    int sum[] = {0,0};        
    int change[] = {0,0};
    for(colour c : colourx){
      change = c.processBlob();
      sum[0] += change[0];
      sum[1] += change[1];
    }
    

    motors[0] = baseSpeed+int(speedScale*sum[0]); 
    motors[1] = baseSpeed+int(speedScale*sum[1]);
    for(int i = 0; i < motors.length; i ++){
      if(motors[i] > 255){
        motors[i] = 255;
      }
      if(motors[i] < 0){
        motors[i] = 0;
      }
    }
  return motors;
    
}
void drawGui(int motors[]){
  textAlign(LEFT);
  fill(255);

  text("Menu:", imgWidth +10, 20*1);
  
  text(menuIndent[1]+"No of Colours:" + maxTarget, imgWidth +20, 20*2);  
  
  if (callibration == 0){
    text(menuIndent[2]+"Callibration: One-Click" , imgWidth +20, 20*3);
  }
  if (callibration == 1){
    text(menuIndent[2]+"Callibration: Area Average" , imgWidth +20, 20*3);
  }
  
  if (callibration == 2){
    text(menuIndent[2]+"Callibration: Area Range" , imgWidth +20, 20*3);
  }
  
  text(menuIndent[3]+"Base Speed: " + baseSpeed, imgWidth +20, 20*4);
  text(menuIndent[4]+"Speed Scale: " + speedScale, imgWidth +20, 20*5);
  text(menuIndent[5]+"Range:" + range, imgWidth +20, 20*6);
  
  
  for (colour c : colourx){
    if(c.colourNo == viewTarget){
      text( "Colour: " + (viewTarget+1) + "/ " + maxTarget, imgWidth +20, 20*8);
    
      stroke(255);
      fill(c.targetRGB[0], c.targetRGB[1], c.targetRGB[2]);
      rectMode(CORNERS);
      rect(imgWidth +20, (20*8 +10), imgWidth +80, (20*9));
      
      fill(255);
      text("R/G/B: " + c.targetRGB[0] + "/" + c.targetRGB[1] + "/" + c.targetRGB[2], imgWidth +20, 20*10);
   
      if (c.behaviour == 1){
        text(menuIndent[6]+"Behaviour: Aggression", imgWidth +20, 20*11);
      }
        
      if (c.behaviour == 2){
        text(menuIndent[6]+"Behaviour: Fear", imgWidth +20, 20*11);
      }
        
      if (c.behaviour == 3){
        text(menuIndent[6]+"Behaviour: Love", imgWidth +20, 20*11);
      }
  
      text(menuIndent[7]+"Threshhold: " + c.thresh, imgWidth +20, 20*12);
  
      text(menuIndent[8]+"Distance: " + c.distThresh, imgWidth +20, 20*13);
  
      text(menuIndent[9]+ "Priority: "+ c.priority, imgWidth +20, 20*14);
      text("Sum L/R: " + c.blobArea[0] + "/" + c.blobArea[1], imgWidth+20, 20*15);
      }
    }
  
  text("Output Values: ", imgWidth +20, 20*17);
  
  text("Motors L/R: " + motors[0] + "/" + motors[1], imgWidth+20, 20*18);
  text("Serial Out: " + serialOut, imgWidth+20, 20*19);
  text("Serial Return: " + serialIn, imgWidth+20, 20*20);
    

  text("Colour Priorities: ", imgWidth + 200, 20*1);
  int counter = 0;
  for(colour c: colourx){
    counter++;
    text("Colour " + counter + ": " + c.priorityPercent, imgWidth + 200, (20*(counter+1)));
  } 
    text("Total: " + sumPriority, imgWidth+ 200, 20*(counter+2));
  if(sumPriority != 100){
    fill(255, 0, 0);
    text("Priorities for all \nColours Must Total 100", imgWidth+200, 20*(counter+3));
    fill(255);
  }
  if(stop == true){
    fill(255, 0, 0);
    text("HANDBRAKE ON", imgWidth+200, 20*(counter+5));
    fill(255);
  }
  else{
    fill(0, 255, 0);
    text("RARING TO GO", imgWidth+200, 20*(counter+5));
    fill(255);
  }
}


void mousePressed(){
  
  for(colour c :colourx){
    if(c.colourNo == viewTarget){
      c.defineTarget();
    }
  }  

}


void keyPressed(){
  if (keyCode == BACKSPACE){
    if (stop == true){
      stop = false;
    }
    else{
       stop = true; 
    }
  }
  if (key == ENTER){
    viewTarget += 1;
    if(viewTarget == maxTarget){
      viewTarget = 0;
    }
  }
  
  if (keyCode == UP){
    mainSelect --;
    if (mainSelect < 1){
      mainSelect = 1;
    }
  }

  if (keyCode == DOWN){
    mainSelect++;
    if (mainSelect > menuIndent.length){
      mainSelect = menuIndent.length;
    }
  }
  if (mainSelect == 1){
    if (keyCode ==LEFT){
      maxTarget --;
      initialiseColour();
    }
    if (keyCode == RIGHT){
      maxTarget ++;
      initialiseColour();      
    }
    if(maxTarget < 0){
      maxTarget = 0;
    }
    
  }   
  
  if (mainSelect == 2){
    if (keyCode == LEFT){
      callibration --;
      initialiseColour();
    }
    if (keyCode == RIGHT){
      callibration ++;
      initialiseColour();
    }
    if(callibration<0){
      callibration = 0;
    }
    if(callibration>2){
      callibration = 2;
    }
  }
  
  if(mainSelect == 3){
    if(keyCode == LEFT){
      baseSpeed --;
    }
    if(keyCode == RIGHT){
      baseSpeed ++;
    }
    if(baseSpeed < 0){
      baseSpeed =0;
    }
    if(baseSpeed > 255){
      baseSpeed = 255;
    }
  }
  if(mainSelect == 4){
    if(keyCode == LEFT){
      speedScale -= 0.25;
    }
    if(keyCode == RIGHT){
      speedScale += 0.25;
    }
    if(speedScale < 0){
      speedScale =0;
    }
    if(speedScale > 4){
      speedScale = 4;
    }
  }
    
  if(mainSelect == 5){
    if(keyCode == LEFT){
      range -= 5;
    }
    if(keyCode == RIGHT){
      range += 5;
    }
    if(range < 0){
      range=0;
    }
    println(speedScale);
  }
  sumPriority = 0;
  for(colour c : colourx){
    
    if(c.colourNo == viewTarget){
      
      if (mainSelect ==6){
        if (keyCode == LEFT){
          c.behaviour --;
        }
        if (keyCode == RIGHT){
          c.behaviour ++;
        }
        if(c.behaviour < 1){
          c.behaviour = 1;
        }
        if(c.behaviour > 3){
          c.behaviour = 3;
        }
      }
      
      if (mainSelect == 7){
        if (keyCode == LEFT){
          c.thresh --;
        }
        if (keyCode == RIGHT){
          c.thresh ++;
        }
        if(c.thresh < 0){
          c. thresh = 0;
        }
        if(c.thresh > 255){
          c.thresh = 255;
        }
        
      }
      
      if (mainSelect == 8){
       if (keyCode == LEFT){
          c.distThresh --;
        }
        if (keyCode == RIGHT){
          c.distThresh ++;
        }
        if(c.distThresh < 0){
          c.distThresh = 0;
        }
      }
      if (mainSelect == 9){
         if (keyCode == LEFT){
            c.priorityPercent -= 5;
            // other priority values += inverse((maxTarget - 1)) 
          }
          if (keyCode == RIGHT){
            c.priorityPercent += 5;

          }
          
          c.priority = map(c.priorityPercent, 0,100,0,1);     
          
          if(c.priority < 0){
            c.priority = 0;
          }
          if(c.priority > 1){
            c.priority = 1;
          }

      }
    }
  sumPriority += c.priorityPercent;
  }
  
  for(int i = 0 ; i < menuIndent.length; i ++){
    menuIndent[i] = "";
  }
  menuIndent[mainSelect] = " -- ";
  
  
}
